# Windows Workers for concourse

CloudFormation... well it can set up the ami instances, but nothing else ever works.
`cfn-init` and `msc` just doesn't go well. 

## Get connected with Remotix.

[It's the best.](http://www.nulana.com/remotix-mac/)

For the Mac:

* Remotix -> Preferences
   * Viewer
      * Host Key: **Right Control** (use this to get in and out of the windows machine).
      * When Connected: **Control Mode**
      * Clipboard: **Auto Synchronize**
* Remotix -> New Server
   * Connection
      * Connection Type: **RDP**
      * Use Agent: **No**
      * Host: **\<worker-ip\>**
   * SSH Tunnel
      * SSH Host: **\<tunnel-ip\>**
      * SSH Username: **\<tunnel-user\>**
      * Auth Type: **Public Key**
      * Private Key File: `$DEPLOYMENT_DIR/artifacts/keypair/id_rsa_bosh`
  * Settings
    * Desktop Size: **Fullscreen**, use `right ctrl, ctrl-left arrow to switch back to OSX`
    * Redirect Files: **Home Folder** (because it's the easiest to navigate to on both ends)

Where do \<worker-\*\> and \<tunnel-\*\> come from:

```shell
cli-concourse-ci\scripts\workers\get_workers

****************************************
* Tunnel configuration

         host: 1.2.3.4
         port: 22
  private_key: /Users/me/deployment-dir/artifacts/deployments/../keypair/id_rsa_bosh
         user: vcap
         
****************************************
* Worker Configs

Windows 64 English (ROLLED): 10.0.17.150
Windows 64 French (ROLLED): 10.0.2.109
Windows 32 English (ROLLED): 10.0.17.110
```
