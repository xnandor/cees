#!/usr/bin/env bash
echo "Copying ROOT/ directory to xwiki/.";
mv /usr/local/tomcat/webapps/ROOT/ /usr/local/tomcat/webapps/xwiki/
echo "Substituting /ROOT/ directory for /xwiki/ in entrypoint.";
sed -i "s|/ROOT/|/xwiki/|g" /usr/local/bin/docker-entrypoint.sh;
echo "Running original docker-entrypoint.sh";
/usr/local/bin/docker-entrypoint.sh xwiki;
