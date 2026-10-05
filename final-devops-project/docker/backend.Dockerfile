FROM python:3.13-alpine
WORKDIR /app
COPY application/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt \
    && python -m pip uninstall -y pip setuptools wheel \
    && rm -rf /usr/local/lib/python3.13/ensurepip \
    && addgroup -g 10001 app && adduser -D -u 10001 -G app app
COPY --chown=app:app application/app.py application/index.html ./
USER 10001:10001
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1
EXPOSE 8080
CMD ["python", "app.py"]
