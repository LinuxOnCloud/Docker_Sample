#!/bin/bash

if [ "$1" == "poiuytrewq" ]; then

cd /home/azureuser/Installationpkg/comman/conf

mv bkp fsarchiver-0.6.19-1.el6.x86_64.rpm
mv ml mailx-12.4-8.el6_6.x86_64.rpm
mv fm mha4mysql-manager-0.55-0.el6.noarch.rpm
mv fn mha4mysql-node-0.54-0.el6.noarch.rpm
mv ml1 mutt-1.5.20-7.20091214hg736b6a.el6.x86_64.rpm
mv mcr mysql-community-release-el6-5.noarch.rpm
mv nc nc-1.84-24.el6.x86_64.rpm
mv pci perl-Config-IniFiles-2.56-1.el6.rf.noarch.rpm
mv pct perl-Config-Tiny-2.12-7.1.el6.noarch.rpm
mv pdm perl-DBD-MySQL-4.013-3.el6.x86_64.rpm
mv pds perl-Digest-SHA1-2.12-2.el6.x86_64.rpm
mv pld perl-Log-Dispatch-2.26-1.el6.rf.noarch.rpm
mv plaw perl-LWP-Authen-Wsse-0.05-1.2.el6.rf.noarch.rpm
mv ppf perl-Parallel-ForkManager-0.7.5-2.2.el6.rf.noarch.rpm
mv ppv perl-Params-Validate-0.92-3.el6.x86_64.rpm
mv ptml perl-Test-Mock-LWP-0.05-1.el6.rf.noarch.rpm
mv ptm perl-Test-MockObject-1.09-4.el6.noarch.rpm
mv puc perl-UNIVERSAL-can-1.15-1.el6.noarch.rpm
mv pui perl-UNIVERSAL-isa-1.03-1.el6.noarch.rpm
mv tyc tokyocabinet-1.4.33-6.el6.i686.rpm
mv uv urlview-0.9-7.el6.x86_64.rpm

mv pogt postgresql96-9.6.6-1PGDG.rhel6.x86_64.rpm
mv pogtc postgresql96-contrib-9.6.6-1PGDG.rhel6.x86_64.rpm
mv pogtl postgresql96-libs-9.6.6-1PGDG.rhel6.x86_64.rpm
mv pogts postgresql96-server-9.6.6-1PGDG.rhel6.x86_64.rpm
mv rep repmgr96-3.3.2-1.rhel6.x86_64.rpm

mv els elasticsearch-5.6.4.rpm
mv jml jemalloc-3.6.0-1.el6.x86_64.rpm
mv res redis-3.2.11-1.el6.x86_64.rpm
mv mono mongodb-org-3.4.10-1.el6.x86_64.rpm
mv monm mongodb-org-mongos-3.4.10-1.el6.x86_64.rpm
mv mons mongodb-org-server-3.4.10-1.el6.x86_64.rpm
mv monsh mongodb-org-shell-3.4.10-1.el6.x86_64.rpm
mv mont mongodb-org-tools-3.4.10-1.el6.x86_64.rpm

mv hp haproxy-1.5.18-1.el6.x86_64.rpm

mv bs bash-4.1.2-48.el6.x86_64.rpm


mkdir -p /home/azureuser/Installationpkg/comman/rpms/core
mkdir -p /home/azureuser/Installationpkg/comman/rpms/utility

mv bash-4.1.2-48.el6.x86_64.rpm /home/azureuser/Installationpkg/comman/rpms/core/.
mv *.rpm /home/azureuser/Installationpkg/comman/rpms/utility/

else
        echo "You are not authourize person, Please leave now."
        exit
fi
