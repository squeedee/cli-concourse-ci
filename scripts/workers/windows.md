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

## Creating new windows workers.
On AWS:

* EC2 -> Launch Instance 
	* Community AMIs
		* Operating System: **Windows**
		* Architecture: **[32|64|whatever you want :D]**
		* Now search:
			* 2012, R2 when possible
			* Find the one with the latest age.
			* Look for 'provided by Amazon'
	* Instance Type
		* **c3.xlarge** when available. It wont always be, try and get close.
		* Network: use the **VPC with the 10.0.0.0/16 CIDR**
		* Subnet: find the **concourse** subnet.
	* Tag Instance
		* Add tag: **Key='Deployment' Value='workers'** (this helps with the `get_workers` script)
	* Configure Security Group
		* choose **Select an existing security group**
		* choose **bosh-ConcourseSecurityGroup-\***

Go for it (review and launch)!

## Deploying on windows
