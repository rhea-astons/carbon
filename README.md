# carbon

Bash backup script using tar incremental files.  
First backup of the month is a full backup.  
Following backups are incremental (unless specified).

By running it daily (i.e with a cron), you would end up with something like this:

```bash
2018
├── 08
│   ├──
│   ├── home-201808010000-full.tar.gz
│   ├── home-201808020000-incr.tar.gz
│   ...
│   ├── home-201808300000-incr.tar.gz
│   ├── home-201808310000-incr.tar.gz
│   └── home.snar
└── 09
    ├── home-201809010000-full.tar.gz
    ├── home-201809020000-incr.tar.gz
    ├── home-201809030000-incr.tar.gz
    └── home.snar
```

## Usage

```bash
usage: ./carbon [-s SOURCE] [-t TARGET] [-e EXCLUDEFILE]
  -s, --source    DIR     Specify the directory to backup (default to $HOME)
  -t, --target    DIR     Specify the target of backups (default to /media/$USER/backups)
  -e, --exclude   FILE    Specify an exclude file (default to /media/$USER/backups/excludelist)
  -f, --force-full        Forces to do a full backup
  -n, --dry-run           Outputs the commands without executing them
  -h, --help              Display help
```

To restore backups, extract a full backup and every incremental backup needed with:
```bash
tar Gxzvf backup.tar.gz
```

You might want to use an exculde file to exclude sensitive or useless (as cache) data from backups.  
This [rsync-homedir-excludes](https://github.com/rubo77/rsync-homedir-excludes) is a good starting point.

