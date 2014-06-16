Description
===========

Installs the OpenStack Database service **Trove** as part of the
OpenStack reference deployment Chef for OpenStack.  Trove is currently
installed from packages.

https://wiki.openstack.org/wiki/Trove

Requirements
============

Chef 11

Cookbooks
---------

The following cookbooks are dependencies:

* openstack-common
* openstack-identity


Usage
=====

api
----
- Installs the API service.

conductor
----
- Installs conductor service.

taskmanager
----
- Installs the taskmanager service.

identity_registration
----
- Registers the endpoints with Keystone.

Attributes
==========

Testing
=====

Please refer to the [TESTING.md](TESTING.md) for instructions for testing the cookbook.

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  Ionut Artarisi (<iartarisi@suse.cz>)              |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2013-2014, SUSE Linux GmbH          |


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
