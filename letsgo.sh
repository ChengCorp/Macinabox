#!/bin/bash

start() {
    if [ -f /config/delete_me_to_reset_v4.txt ]; then
        # Refresh the executable content from the image on EVERY run.
        #
        # Upstream copied /app/Macinabox/* into /config/ only on the FIRST run,
        # then executed /config/run/unraid.sh forever after. That makes appdata
        # permanently shadow the image: once a VM exists, pulling a newer
        # container changes nothing, because the old script keeps running. Any
        # fix shipped in a new image silently never reaches an existing install.
        #
        # Only image-owned content is replaced. custom_opencore/ is user-supplied
        # and is never touched; the *_is_in_*_share state flags are left alone.
        rm -rf /config/run /config/bootloader
        cp -r /app/Macinabox/run /app/Macinabox/bootloader /config/
        cp -f /app/Macinabox/macinabox.xml /config/macinabox.xml 2>/dev/null || true
        cp -f /app/Macinabox/macinabox.png /config/macinabox.png 2>/dev/null || true
        chmod -R 777 /config/
        cd /config/run
        ./unraid.sh  
    else
        rm -f /config/*.xml
        rm -f /config/*.txt
        rm -f /config/macinabox.png
        rm -rf /config/bootloader
        rm -rf /config/custom_opencore
        rm -rf /config/stock_opencore
        rm -rf /config/run
        cp -r /app/Macinabox/* /config/
        chmod -R 777 /config/
        cd /config/run
        ./unraid.sh  
    fi
}

start

sleep "$SLEEPTIME"
