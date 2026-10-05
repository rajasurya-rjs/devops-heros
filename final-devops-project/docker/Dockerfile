FROM python:3.13-alpine
# The app uses no third-party packages; remove build/installer packages and
# pip's vendored dependency tree from the runtime image.
RUN python -m pip uninstall -y pip setuptools wheel msgpack urllib3 \
    && rm -rf /usr/local/lib/python3.13/ensurepip
RUN addgroup -g 10001 app && adduser -D -u 10001 -G app app \
    && mkdir /data && chown app:app /data
WORKDIR /app
COPY --chown=app:app application/app.py application/index.html ./
USER 10001:10001
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 DB_PATH=/data/notes.db
EXPOSE 8080
CMD ["python", "app.py"]
