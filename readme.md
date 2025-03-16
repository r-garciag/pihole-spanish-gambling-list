# Spanish Gambling Adlist
A blocklist of every gambling site allowed in Spain. It auto-updates everyday using Github Actions.

## Description

This blocklist is 100% compatible with [PiHole](pihole.net) and [Adguard Home](https://github.com/AdguardTeam/AdGuardHome) It uses the Consumer Ministry's list of allowed gambling websites in Spain.

```
https://raw.githubusercontent.com/r-garciag/pihole-spanish-gambling-list/refs/heads/main/es_gambling_hosts.txt
```

### About the adlist itslef

The adlist will get updated as soon as the oficial site lists a new site, the last update will be printed on the list itself. 

## Instructions for the following AdBlockers
- PiHole
- AdGuard Home

### Using this list with PiHole

1. Go to your PiHole web interface.
2. Go to `Group Management` and then to `Adlists`. 
3. Paste the list url (link above) and click on `Add`.
4. Update Gravity! (under `Tools` section).
5. Profit!


### Using this list with AdGuard Home
1. Go to `Filters` / `DNS blocklists`.
2.  Press `Add blocklist`.
3.  Select `Add a custom list`.
4.  Chose name and paste the URL (link above).

### Copyright
```
2025, Raúl García
```

### Credits
* Thanks to _PiHole_ for creating an awesome tool.
* Thanks to _Adguard_ for developing a great solution.
* Spanish _Ministerio de Consumo_ for providing the websites urls.
