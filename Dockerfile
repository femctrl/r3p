FROM fredblgr/ubuntu-novnc:20.04

ENV RESOLUTION=1707x1607

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
