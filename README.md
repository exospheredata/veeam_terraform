# Terraform Examples for deploying Veeam
This Repository contains example Terraform templates for use with the Veeam Chef cookbook to deploy infrastructure required to support Veeam Environments.


## Terraform Templates
| Name | Deployment Type | Requires Chef Server | Description |
| --- | --- | --- | --- |
| [veeam_standalone_full](vmware/chef_server/veeam_standalone_full) | VMware | X | This set of templates will deploy Veeam Backup and Replication server in a complete deployment along with an optional number of Veeam VMware Proxies on VMware using Chef Server. |
| [veeam_proxy](vmware/chef_server/veeam_proxy) | VMware | X | This set of templates will deploy one or more Veeam VMware Proxy Servers on VMware using Chef Server. |
| [no_chef_server:veeam_standalone_full](vmware/no_chef_server/veeam_standalone_full) | VMware |  | This set of templates will deploy Veeam Backup and Replication server in a complete deployment along with an optional number of Veeam VMware Proxies on VMware using Chef-Solo mode with the Chef Client. |
| [no_chef_server:veeam_proxy](vmware/no_chef_server/veeam_proxy) | VMware |  | This set of templates will deploy one or more Veeam VMware Proxy Servers on VMware using Chef-Solo mode with the Chef Client. |

## Contribute
 - Fork it
 - Create your feature branch (git checkout -b my-new-feature)
 - Commit your changes (git commit -am 'Add some feature')
 - Push to the branch (git push origin my-new-feature)
 - Create new Pull Request

## License and Author

_Note: This repository is not officially supported by or released by Veeam Software, Inc._

- Author:: Exosphere Data, LLC ([chef@exospheredata.com](mailto:chef@exospheredata.com))

```text
Copyright 2018 Exosphere Data, LLC
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
except in compliance with the License. You may obtain a copy of the License at:

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the
License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
either express or implied. See the License for the specific language governing permissions
and limitations under the License.
```
