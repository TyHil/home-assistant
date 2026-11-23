# Home Assistant Setup and Backup

Home Assistant setup and backup instructions

## Setup

1. Clone the repo with `git clone https://github.com/TyHil/home-assistant.git ~/home-assistant` and `cd ~/home-assistant`.

1. Follow instructions at https://www.home-assistant.io/installation/linux#docker-compose. Reconcile `docker-compose.yml` from Home Assistant and the repo.

1. Run `docker compose up -d`.

1. Follow instructions at https://github.com/TyHil/cloudflared to set up Cloudflared. In Home Assistant under Settings > System > Network > HTTP server > Reverse proxy turn on "Trust X-Forwarded-For" and add a trusted proxy set to 172.20.0.2, matching the Cloudflared Docker Compose pinned IP. Restart Home Assistant as instructed.

## Backup

1. Edit `config/configuration.yaml` and add the below lines to turn off the database cleanup, normally pinned to after 4am.

   ``` yaml
   recorder:
     auto_purge: false
     purge_keep_days: 10
   ```

1. In Home Assistant, create an automation with the below YAML, to schedule the database cleanup for earlier.

   ``` yaml
   alias: Run Home Assistant database cleanup daily at 12:05am
   triggers:
     - trigger: time
       at: '00:05:00'
   actions:
     - action: recorder.purge
       data:
         keep_days: 10
         repack: '{{ now().weekday() == 6 and 8 <= now().day <= 14 }}'
   ```

1. In Home Assistant under Settings > System > Backups > Automatic backup > Configure backup settings > Backup cycle set "Time" to Custom and "Backup at" to 2:05am.

1. Run `docker compose restart homeassistant` to restart Home Assistant.

1. Set up [Tailscale](https://tailscale.com/) and add your local server's ssh keys to your remote server.

1. Setup `./backup_script.sh`.

    a. Run `cp .env.backup.example .env.backup` and set your Uptime Kuma push URLs (see https://github.com/TyHil/uptime-kuma) for local and remote backups in `.env.backup`.
    
    a. Run `sudo mkdir -p /mnt/Backup` to create a mount directory. Then Run `lsblk -f`, identify your drives UUID, and fill it in to and run `echo "UUID=<UUID>  /mnt/Backup  ext4  defaults,nofail,x-systemd.automount  0  2" | sudo tee -a /etc/fstab` to create a fstab entry. Finally, run `sudo systemctl daemon-reload`, `sudo umount /mnt/Backup`, and `sudo systemctl start mnt-Backup.automount`. You should see the contents of your drive, automatically mounted, with `ls /mnt/Backup`.
    
    a. Update paths in `./backup_script.sh`.

1. Run `sudo cp home-assistant-backup.example.service /etc/systemd/system/home-assistant-backup.service` and `sudo cp home-assistant-backup.example.timer /etc/systemd/system/home-assistant-backup.timer` and edit the new service file to have the correct `User`, `WorkingDirectory`, and `ExecStart` for you. Then run `sudo systemctl daemon-reload`, `sudo systemctl enable home-assistant-backup.timer`, and `sudo systemctl start home-assistant-backup.timer`.

1. Update paths and add the contents of `example.bash_aliases` to your `~/.bash_aliases` or run `cp example.bash_aliases ~/.bash_aliases`.

1. Finally run `source ~/.bash_aliases`, check the next backup time with `home-assistant-backup status`, and backup now with `home-assistant-backup backup`.
