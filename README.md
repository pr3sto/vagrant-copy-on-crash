# vagrant-state-change-listener
Vagrant plugin for listening vm state changes and executing actions on changes.

[![Gem Version](https://badge.fury.io/rb/vagrant-state-change-listener.svg)](https://badge.fury.io/rb/vagrant-state-change-listener)

## Installation

```console
foo@bar:~$ vagrant plugin install vagrant-state-change-listener
```

## Usage

Use **listen-state-changes** command to listen vm state changes. When state is changed (e.g., from *running* to *stopped*), command executes given actions (shell commands).

### Command syntax

```console
foo@bar:~$ vagrant listen-state-changes <vm name> <actions> [options]
```

**\<vm name\>** - name of virtual machine

**\<actions\>** - shell commands to execute after state change

### Options

**-f (--first-state) FSTATE** - If vm changes it's state from FSTATE, plugin executes **\<actions\>**

**-s (--second-state) SSTATE** - If vm changes it's state to SSTATE, plugin executes **\<actions\>"**

**-l (--latency SECONDS)** - Delay (in seconds) between checking for changes. Default: 1 sec

**-a (--auto-stop)** - Stop listening after first state change (after executing **\<actions\>**)

### Examples

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!'
```

When vm with name *default* changes it's state, *Changed!* is printed to console. Terminal is blocked until the user manually terminates command

---

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!' -a
```

When vm with name *default* changes it's state, *Changed!* is printed to console and command terminates

---

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!' -f running
```

When vm with name *default* changes it's state from *running* to any other state, *Changed!* is printed to console

---

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!' -s stopped
```

When vm with name *default* changes it's state to *stopped* from any other state, *Changed!* is printed to console

---

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!' -f running -s stopped
```

When vm with name *default* changes it's state from *running* to *stopped*, *Changed!* is printed to console

---

```console
foo@bar:~$ vagrant listen-state-changes default 'echo Changed!' -l 10
```

When vm with name *default* changes it's state, *Changed!* is printed to console. Delay between state checking - 10 sec\

## Example

```console
# in other terminal: $ vagrant up

foo@bar:~$ vagrant listen-state-changes default 'echo Changed!'

# in other terminal: $ vagrant destroy

VM state changed from 'running' to 'stopped'
Executing actions: 'echo Changed!'
Changed!
Actions executed successfully: true

VM state changed from 'stopped' to 'not created'
Executing actions: 'echo Changed!'
Changed!
Actions executed successfully: true
```

With **--auto-stop** option:

```console
# in other terminal: $ vagrant up

foo@bar:~$ vagrant listen-state-changes default 'echo Changed! -a

# in other terminal: $ vagrant destroy

VM state changed from 'running' to 'stopped'
Executing actions: 'echo Changed!'
Changed!
Actions executed successfully: true
Stopping listening ...

foo@bar:~$
```
