#!/usr/bin/python3
# Copyright (C) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE-CODE in the project root for license information.

"""vFXT cluster health status checks."""

# standard imports
import json
import logging
import os
import re
import sys
from time import sleep, time

# from requirements.txt
import pytest
from fabric import Connection
from paramiko.ssh_exception import NoValidConnectionsError
from scp import SCPClient

# local libraries
from lib.helpers import (get_unused_local_port, run_averecmd, run_ssh_commands,
                         upload_gsi)


class TestVfxtClusterStatus:
    """Basic vFXT cluster health tests."""

    def test_ping_node_ips(self, node_ips, ssh_con, test_vars):  # noqa: F811
        """Ping the node IPs from the controller."""
        commands = []
        for node_ip in node_ips:
            commands.append("ping -c 3 {}".format(node_ip))
        run_ssh_commands(ssh_con, commands)

    def test_node_health(self, averecmd_params, node_names, test_vars):  # noqa: F811
        """Get the node IPs and store them in test_vars."""
        log = logging.getLogger("test_node_health")

        node_ips = {}  # will store a map of node names and IPs
        for node in node_names:
            timeout_secs = 60
            time_start = time()
            time_end = time_start + timeout_secs
            while time() <= time_end:
                result = run_averecmd(**averecmd_params,
                                      method="node.get", args=node)
                node_state = result[node]["state"]
                log.info('Node {0} has state "{1}"'.format(node, node_state))
                if node_state == "up":
                    # Save the node IPs while we're here.
                    node_ips[node] = [x["IP"] for x in result[node]["clusterIPs"]]
                    if result[node]["clientFacingIPs"]["vserver"]:
                        node_ips[node].append(result[node]["clientFacingIPs"]["vserver"][0]["IP"])
                    break
                sleep(10)
            assert node_state == "up"

        if node_ips:
            test_vars["node_ips"] = node_ips

    def test_ha_enabled(self, averecmd_params):  # noqa: F811
        """Check that high-availability (HA) is enabled."""
        result = run_averecmd(**averecmd_params, method="cluster.get")
        assert result["ha"] == "enabled"

    def test_basic_fileops(self, mnt_nodes, scp_con, ssh_con, test_vars):  # noqa: E501, F811
        """
        Quick check of file operations.
        See check_node_basic_fileops.sh for more information.
        """
        if ("storage_account" not in test_vars) or (not test_vars["storage_account"]):
            pytest.skip("no storage account")

        script_name = "check_node_basic_fileops.sh"
        scp_con.put(
            "{0}/test/{1}".format(test_vars["build_root"], script_name),
            r"~/.",
        )
        commands = """
            chmod +x {0}
            ./{0}
            """.format(script_name).split("\n")
        run_ssh_commands(ssh_con, commands)

    def test_ping_vservers(self, ssh_con, test_vars):  # noqa: F811
        """Ping the vserver IPs from the controller."""
        commands = []
        for vs_ip in test_vars["cluster_vs_ips"]:
            commands.append("ping -c 3 {}".format(vs_ip))
        run_ssh_commands(ssh_con, commands)


class TestVfxtSupport:
    """
    Test/support artifact gathering.
    These tests should attempt to run even if deployment has failed.
    """

    def test_for_alerts_active(self, averecmd_params, test_vars):  # noqa: F811
        """Check the cluster for active conditions and events."""
        log = logging.getLogger("test_for_alerts_active")
        conditions = run_averecmd(
            **averecmd_params, method="alert.conditions", args="yellow"
        )
        if conditions:
            test_vars["collect_gsi"] = True
            log.error('Active "yellow+" conditions: {}'.format(conditions))

        events = run_averecmd(
            **averecmd_params, method="alert.events", args="yellow"
        )
        if events:
            test_vars["collect_gsi"] = True
            log.error('Active "yellow+" events: {}'.format(events))

        assert(not conditions and not events)

    def test_for_alerts_past(self, averecmd_params, test_vars):  # noqa: F811
        """Check the cluster for historical conditions and events."""
        log = logging.getLogger("test_for_alerts_past")
        alerts = (run_averecmd(**averecmd_params, method="alert.history") +
                  run_averecmd(**averecmd_params, method="alert.getHistory"))

        msgs_to_ignore = [
            r"are being rebalanced.\s+The vserver\(s\) will be suspended until the rebalance is complete.",
            r"HA is now fully configured",
            r"is checking for data to flush that was not mirrored. Check cluster activity for progress",
            r"is initializing.\s+Access is suspended for this node.",
            r"joined the cluster.",
            r"New caching policy: Full Caching {read-write, writeback time: \d+, attribute checking: never, nlm caching: \d}",
            r"that is configured for HA is currently running in write-through mode without an assigned partner node. This situation can be caused by HA reconfiguration, cluster reconfiguration, or an internal error.",
            r"that is configured for HA is unable to communicate with its HA partner node",
            r"The caching policy for core filer msazure has been modified",
            r"Vserver.+vserver.+is having a problem on some of the nodes in the cluster. All affected interfaces have been failed over.",
        ]

        alerts_without_matches = []
        for alert in alerts:
            exp_msg_found = False
            for ignore_msg in msgs_to_ignore:
                for field in ["message", "details", "xmldescription"]:
                    if field in alert and re.search(ignore_msg, alert[field]):
                        log.debug("Ignorable message found: ".format(alert))
                        exp_msg_found = True
                        break  # out of field loop
                if exp_msg_found:
                    break  # out of ignore_msg loop
            if not exp_msg_found:
                alerts_without_matches.append(alert)

        log.error("Alerts without ignorable messages ({0} found): {1}".format(
            len(alerts_without_matches),
            json.dumps(alerts_without_matches, indent=4)
        ))

        ###############################################################################
        msgs_without_matches = set()
        for alert in alerts_without_matches:
            if "message" in alert and "details" in alert:
                msgs_without_matches.add("message: {0}\n\ndetails:{1}".format(
                    alert["message"].replace("\n", r"\n"),
                    alert["details"].replace("\n", r"\n")))
            elif "message" in alert:
                msgs_without_matches.add(alert["message"].replace("\n", r"\n"))
            elif "details" in alert:
                msgs_without_matches.add(alert["details"].replace("\n", r"\n"))
            elif "xmldescription" in alert:
                msgs_without_matches.add(alert["xmldescription"].replace("\n", r"\n"))
        mwm = sorted(list(set(msgs_without_matches)))
        log.error("messages without matches ({}):\n".format(
            len(mwm)) + ("\n" + ("="*40) + "\n") .join(mwm)
        )
        ###############################################################################

        if alerts_without_matches:
            test_vars["collect_gsi"] = True

        assert(not alerts_without_matches)

    def test_for_cores(self, averecmd_params, test_vars):  # noqa: F811
        """Check the cluster for cores."""
        log = logging.getLogger("test_for_cores")
        node_cores = run_averecmd(
            **averecmd_params, method="support.listCores", args="cluster"
        )
        cores_found = False
        for cores in node_cores.values():
            if len(cores):
                cores_found = True
                break

        if cores_found:
            test_vars["collect_gsi"] = True
            log.error("Cores found: {}".format(node_cores))

        assert(not cores_found)

    def test_collect_gsi(self, averecmd_params, test_vars):  # noqa: F811
        """Collect/upload a GSI if another test requested it."""
        if "collect_gsi" in test_vars:
            if test_vars["collect_gsi"]:
                upload_gsi(averecmd_params)  # collect/upload a "normal" GSI
            test_vars.pop("collect_gsi")

    def test_artifacts_collect(self, averecmd_params, node_names, scp_con, test_vars):  # noqa: F811, E501
        """
        Collect test artifacts (node logs, rolling trace) from each node.
        Artifacts are stored to local directories.
        """
        log = logging.getLogger("test_collect_artifacts")
        artifacts_dir = "vfxt_artifacts_" + test_vars["atd_obj"].deploy_id
        os.makedirs(artifacts_dir, exist_ok=True)

        log.debug("Copying logs from controller to {}".format(artifacts_dir))
        for lf in ["vfxt.log", "enablecloudtrace.log", "create_cluster_command.log"]:
            scp_con.get("~/" + lf, artifacts_dir)

        log.debug("Copying SSH keys to the controller")
        scp_con.put(test_vars["ssh_priv_key"], "~/.ssh/.")
        scp_con.put(test_vars["ssh_pub_key"], "~/.ssh/.")

        last_error = None
        for node in node_names:
            node_dir = artifacts_dir + "/" + node
            node_dir_log = node_dir + "/log"
            node_dir_trace = node_dir + "/trace"
            log.debug("node_dir_log = {}, node_dir_trace = {}".format(
                node_dir_log, node_dir_trace))

            # make local directories to store downloaded artifacts
            os.makedirs(node_dir_trace, exist_ok=True)
            os.makedirs(node_dir_log, exist_ok=True)

            # get this node's primary cluster IP address
            node_ip = run_averecmd(**averecmd_params,
                                   method="node.get",
                                   args=node)[node]["primaryClusterIP"]["IP"]

            log.debug("Tunneling to node {} using IP {}".format(node, node_ip))

            # get_unused_local_port actually uses the port to know it's
            # available before making it available again and returning the
            # port number. Rarely, there is a race where the open() call
            # below fails because the port is not yet fully available
            # again. In those cases, try getting a new port.
            for port_attempt in range(1, 11):
                tunnel_local_port = get_unused_local_port()
                with Connection(test_vars["public_ip"],
                                user=test_vars["controller_user"],
                                connect_kwargs={
                                    "key_filename": test_vars["ssh_priv_key"],
                                }).forward_local(local_port=tunnel_local_port,
                                                 remote_port=22,
                                                 remote_host=node_ip):
                    node_c = Connection("127.0.0.1",
                                        user="admin",
                                        port=tunnel_local_port,
                                        connect_kwargs={
                                            "password": os.environ["AVERE_ADMIN_PW"]
                                        })
                    try:
                        node_c.open()

                        # If port_attempt > 1, last_error had the exception
                        # from the last iteration. Clear it.
                        last_error = None
                    except NoValidConnectionsError as ex:
                        last_error = ex
                        exp_err = "Unable to connect to port {} on 127.0.0.1".format(tunnel_local_port)
                        if exp_err not in str(ex):
                            raise
                        else:
                            log.warning("{0} (attempt #{1}, retrying)".format(
                                        exp_err, str(port_attempt)))
                            continue  # iterate

                    scp_client = SCPClient(node_c.transport)
                    try:
                        # Calls below catch exceptions and report them to the
                        # error log, but then continue. This is because a
                        # failure to collect artifacts on one node should not
                        # prevent collection from other nodes. After collection
                        # has completed, the last exception will be raised.

                        # list of files and directories to download
                        to_collect = [
                            "/var/log/messages",
                            "/var/log/xmlrpc.log",

                            # assumes rolling trace was enabled during deploy
                            "/support/trace/rolling",

                            # TODO: 2019-0219: turned off for now
                            # "/support/gsi",
                            # "/support/cores",
                        ]
                        for tc in to_collect:
                            log.debug("SCP'ing {} from node {} to {}".format(
                                    tc, node, node_dir_log))
                            try:
                                scp_client.get(tc, node_dir_log, recursive=True)
                            except Exception as ex:
                                log.error("({}) Exception caught: {}".format(
                                        node, ex))
                                last_error = ex
                    finally:
                        scp_client.close()
                log.debug("Connections to node {} closed".format(node))
                break  # no need to iterate again

        if last_error:
            log.error("See previous error(s) above. Raising last exception.")
            raise last_error


if __name__ == "__main__":
    pytest.main(sys.argv)
