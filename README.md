# Echelon Snapshot Importer

The script can be used to interactively download and import a snapshot of Echelon blockchain node data folder on your server. Snapshots are exported daily and hosted by [ech.world](https://ech.world)

## Usage

You can download the script and run it on your server, the script
* prompts for wanted download folder
* prompts for Echelon node's data folder path
* downloads the latest snapshot from ech.world
* prompts for confirmation to proceed
* stops the node on your server
* removes the existing data folder
* extracts the downloaded snapshot package to data folder
* starts the node

Alternatively you can run the following command on your server which will download the script from Github and run it

```
bash <(wget -qO- https://raw.githubusercontent.com/ech-world/ech-snapshot-importer/main/import-snapshot.sh)
```

Please notice that using the script is totally on your own responsibility. I’ve done my best to make it safe and reliable but it’s an MIT licensed release, I am not liable if something unexpected happens that you don’t like

## Importing the snapshot manually

You can also download the snapshot and import it to your server manually, you can find the download link in [ech.world](https://ech.world/snapshots)
