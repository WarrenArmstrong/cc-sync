import json

def handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps('Hello')
    }

# import awsgi
# from flask import Flask, jsonify

# app = Flask(__name__)


# @app.route("/hello")
# def index():
#     return jsonify(status=200, message="OK")


# def handler(event, context):
#     return awsgi.response(app, event, context, base64_content_types={"image/png"})
