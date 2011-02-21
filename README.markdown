Introduction
------------

Clouder is a way to easily run a command on one or many remote servers. It logs into a server via SSH, uploads either the entire current project, or some specified project, installs any specified gems, and runs a specified command in the project's directory.

Usage
-----

To create a clouder project:

	$ cloud init

This creates a Cloudfile in the current directory. Just update the Cloudfile with your information and you're all set to go.

To run a command, simply use:

	$ cloud run

Notes
-----

Clouder runs commands blockingly, so if you have a long task that you want run, and/or multiple servers you want to run it on, it's probably a good idea to use screen. For example,

	$ screen -dmS [Your Command]
