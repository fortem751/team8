if [ -f /var/log/messages ]; then 
    echo "database exists, starting dashboard"
else
    docker run -v /tmp/prom:/tmp/prom -e DATABASE_URL=sqlite3:////tmp/prom/file.sqlite3 prom/promdash ./bin/rake db:migrate
fi

echo "Now starting dashboard..."
docker run -v /tmp/prom:/tmp/prom -p 3000:3000 -e DATABASE_URL=sqlite3:////tmp/prom/file.sqlite3 prom/promdash 
