FROM fredblgr/framac-novnc:latest

ENV RESOLUTION=1707x1607

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
