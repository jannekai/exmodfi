
Updating a web site is trivial when using a dynamic language like PHP. For example, the [previous incarnation](article/experiences-with-silex-php-framework) of this web site was run directly from a checked out repository and pulling in changes was enough to update the website. Using [Phoenix Framework](http://phoenixframework.org), updating becomes more complicated because the website and server are integrated.

Without automating the update process, you end up forgetting what to do exactly and updating website ends up being an error prone process. In this post I go over my solution to automate the update process using [ansible](http://www.ansible.com/).

## Deployment environment

Automating any deployment process is dependent on the target environment. This web server is running on a EC2 virtual server using an Ubuntu 14.04 release. The web server stack consists of an [nginx](http://nginx.org/) front-end proxy forwarding incoming traffic to the phoenix web server.

The web server is run by a non-privileged user, and the server is compiled and run in that users _$HOME_ directory. The full source code for the web site is available at [GitHub repository](https://github.com/jannekai/exmodfi).

## Updating phoenix web server

The manual tasks required to update the web server were:

* SSH into server
* Pull committed changes from GitHub repository
* Compile a new version of the web server
* Update nginx configuration
* Update webserver upstart startup script
* Restart nginx and the phoenix web server

I could have written a simple bash script to implement all of these steps, but luckily there is a better way to do it.

## Enter ansible

As described in the [Ansible introduction](http://www.ansible.com/how-ansible-works), ansible is an automation engine for managing servers. It works by connecting to servers with SSH and running small programs performing specified tasks. This is exactly what is needed for updating our server.

The biggest win over custom scripts is that the tasks are specified in higher abstraction level than shell commands. This makes the tasks both more robust and portable than custom scripts.

## Organizing files and directories

Because ansible uses convention over configuration, file and directory names have semantic meaning. [Ansible best practices](http://docs.ansible.com/playbooks_best_practices.html#directory-layout) describes a standard way to organize files and directories that you should follow in most cases.

The final result for updating web server consists from the following files and directories.

```nohighlight
ansible.cfg                 # General ansible configuration
update.yml                  # Main playbook for updating the web site
Makefile                    # Ansible commands for running tasks
inventory\
    hosts                   # Target servers
group_vars\             
    web.yml                 # Variables for host group web
tasks\
    update_web_server.yml   # Tasks for updating server
templates\
    nginx.conf.j2           # Nginx configuration template
    upstart.conf.j2         # Upstart configuration template
```

## Configuring ansible

Ansible has many configuration options for configuring how to connect to servers and handling differences in server environments. Luckily most of the settings [have sane defaults](http://docs.ansible.com/intro_configuration.html) and usually most of them don't require any changes. 

I prefer having all required files for any project stored in repository whenever possible. So instead of using __~/.ansible.cfg__ or environment variables I used __ansible.cfg__ file in the directory where commands are run. The same reason is why I used __inventory/hosts__ file instead of configuring servers in global __/etc/ansible/hosts__.

__ansible.cfg__
```ini
[defaults]
private_key_file = ~/.ssh/aws-key.pem
remote_user = janneka
inventory = inventory/hosts
```

## Inventory

In ansible lingo, inventory is a categorized set of hosts to connect. For this website there is only one server and it is placed in the group __web__. The [ansible inventory documentation](http://docs.ansible.com/intro_inventory.html) describes how you can compose groups with more complex server configurations. You can also use dynamic inventories, where host data is queried from external system like EC2 or LDAP.

__inventory\hosts__
```ini
[webservers]
www.mod.fi
```

## Variables

Parametrizing update process using variables is not required since we only have a single target host and the values could be hard coded in scripts. Using variables makes scripts and templates easier to understand, since they give meaning to things like paths.

Placing the __web.yml__ file under __group_vars__ directory means by convention to apply these variables whenever a command is run against a host belonging to the __web__ group. See the [ansible variables documentation](https://docs.ansible.com/playbooks_variables.html) for more information about variables, facts and built-ins and how they are applied.

__group_vars/web.yml__
```
server_name: exmodfi
server_user: exmodfi
dns_base_name: mod.fi
dns_full_name: www.mod.fi
home_dir: /home/exmodfi
deployment_dir: /home/exmodfi/deploy
```

## Update playbook

Playbook is a term ansible uses for configuration management script. They are the highest level building blocks for describing a sequence of tasks. As described in the [best practices](http://docs.ansible.com/playbooks_best_practices.html) documentation, playbooks should be organized hierarchically starting from highest level and including lower level playbooks and eventually tasks. 

The __update.yml__ playbook specifies that the task is to be run for each host belonging to the web group, run as root by default and includes the __update_web_servers.yml__ file containing the actual tasks.

__update.yml__
```
- hosts: web
  become: yes
  tasks:
  - include: tasks/update_web_server.yml
```

## Tasks

Tasks are a sequence of steps for performing operations at target host. The __update_web_servers.yml__ file contains everything required to perform the steps specified as requirement for updating the web site.

Notice that when the first git task is run, we register a conditional named __repository_updated__. This allows us to run other tasks only when there were actual changes in the repository.

__tasks/update_web_server.yml__
```
- name: Update or fetch for first time the source files for application
  git: repo=https://github.com/jannekai/exmodfi.git dest={{deployment_dir}}
  register: repository_updated
  become_user: "{{server_user}}"

- name: Install and update Hex and Rebar
  shell: mix do local.hex --force, local.rebar --force
  environment:
    MIX_ENV: prod
  become_user: "{{server_user}}"
  when: repository_updated.changed

- name: Build static assets with brunch
  shell: brunch build --production chdir={{deployment_dir}}
  become_user: "{{server_user}}"
  when: repository_updated.changed

- name: Build the server
  shell: mix do deps.get, deps.compile, compile chdir={{deployment_dir}}
  environment:
    MIX_ENV: prod
  become_user: "{{server_user}}"
  when: repository_updated.changed

- name: Render upstart configuration template
  template: src=upstart.conf.j2 dest=/etc/init/{{server_name}}.conf
  when: repository_updated.changed

- name: Render nginx configuration template
  template: src=nginx.conf.j2 dest=/etc/nginx/sites-available/{{server_name}}
  when: repository_updated.changed

- name: Restart nginx service
  service: name=nginx state=restarted
  when: repository_updated.changed

- name: Restart exmodfi service
  service: name=exmodfi state=restarted
  when: repository_updated.changed
```

## Templates

The final ansible configuration we have are the nginx configuration and an upstart script for running the phoenix web server. These templates are written with variables substituted by the render tasks described in the __update_web_server__ task.

__templates/nginx.conf.j2__
```
upstream {{server_name}} {
    server 127.0.0.1:8080;
}

server {
    listen       80;
    server_name  {{dns_base_name}};
    return       301 http://{{dns_full_name}}$request_uri;
}

server {
    listen 80;
    server_name {{dns_full_name}};

    location / {
        try_files $uri @proxy;
    }

    location @proxy {
        include proxy_params;
        proxy_redirect off;
        proxy_pass http://{{server_name}};
    }
}
```

__templates/upstart.conf.j2__

```
description "Launches {{dns_full_name}} site using Phoenix Framework"
author "Janne Kaistinen"

start on runlevel [2345]
stop on runlevel [!2345]

setuid {{server_user}}
setgid {{server_user}}

console log

respawn

chdir {{deployment_dir}}

env HOME={{home_dir}}
env MIX_ENV=prod
env PORT=8080
env LANG=en_US.UTF-8

post-start exec echo "{{server_name}} was (re)started on $(date)"

exec elixir --name {{server_name}}@{{dns_base_name}} -S mix phoenix.server
```

__Makefile__

Using make is a great way to document how to run the tasks. In this case we have a couple of helpers for testing that we can connect to hosts using __make ping__ and for grabbing latest logs from all web servers with __make logs__.

The command __make update__ is the main task for updating web server.

```
# Ping all servers
ping:
  ansible all -m ping

# Grab latest 100 lines of logs from all servers
logs:
  ansible webservers -m shell -a "tail -n100 /var/log/upstart/exmodfi.log" --become

update:
  ansible-playbook update.yml

.PHONY: ping logs update
```

## Where next

This was a short overview of how ansible can be used to update a phoenix web server. For more information about configuring ansible, the on-line documentation is pretty good. 

For those new to ansible, I can recommend the [Ansible Up & Running](http://shop.oreilly.com/product/0636920035626.do) book. It does a better job in gradually explaining how ansible works and doesn't try to cover all details when not needed.


