# Ping all servers
ping:
	ansible all -m ping

# Grab latest 100 lines of logs from all servers
logs:
	ansible webservers -m shell -a "tail -n100 /var/log/upstart/exmodfi.log" --become

update:
	ansible-playbook update.yml

.PHONY: ping logs update
