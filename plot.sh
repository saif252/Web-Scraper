#!/bin/bash

# Config
DB_USER="root"
DB_PASS="" 
DB_NAME="crypto_db"
ASSET_ID=1


# Price Last 24 Hour
price_24hr() {
    TXT_FILE="price_24hr.txt"
    OUTPUT_PNG="price_24hr.png"
    # Save the relevent timestamp and prices to price_24hr.txt
    /Applications/XAMPP/xamppfiles/bin/mysql -u "$DB_USER" -h 127.0.0.1 -P 3306 -D "$DB_NAME" -B -N -e "
        SELECT DATE_FORMAT(timestamp,'%Y-%m-%d %H:%i:%s'), price
        FROM asset_metrics
        WHERE asset_id=$ASSET_ID
            AND timestamp >= NOW() - INTERVAL 24 HOUR
        ORDER BY timestamp;
    " > "$TXT_FILE"

    # Check if file has content
    if [[ ! -s "$TXT_FILE" ]]; then
        echo "Error: '$TXT_FILE' is empty. Cannot plot."
        exit 1
    fi

    # Plot (Gnuplot)
    gnuplot <<-EOF
        set terminal png size 1000,600
        set output "$OUTPUT_PNG"
        set datafile separator "\t"
        set xdata time
        set timefmt "%Y-%m-%d %H:%M:%S"
        set format x "%H:%M"
        set xlabel "Time"
        set ylabel "Price (USD)"
        set title "Bitcoin Price - Last 24 Hours"
        set grid
        plot "$TXT_FILE" using 1:2 with linespoints title "Price" lt rgb "blue" lw 2 pt 7
EOF

    echo "Price (24hr) plot saved to $OUTPUT_PNG"
}


# Main Menu
case "$1" in
    price_24hr)
        price_24hr
        ;;
    *)
        echo "Unknown plot type: $1"
        echo "Available types: price_24hr"
        exit 1
        ;;
esac
