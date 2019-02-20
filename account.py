from flask import Flask, request
from flask_restful import Resource, Api
from flaskext.mysql import MySQL
from json import dumps
from flask_jsonpify import jsonify

app = Flask(__name__)
api = Api(app)

mysql = MySQL()
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = 'Jirayu1001'
app.config['MYSQL_DATABASE_DB'] = 'userdb'
app.config['MYSQL_DATABASE_HOST'] = '35.184.161.198'
mysql.init_app(app)

conn = mysql.connect()
c = conn.cursor()

class checkemailUsername(Resource):
    def get(self,email,username):
        c.execute("select count(*) from userdb where email = %s", email)
        check_email = c.fetchall()
        for row_validation in check_email:
            email_check = row_validation[0]
        validation = dict(validation_email = email_check)
        c.execute("select count(*) from userdb where username = %s",username)
        check_username = c.fetchall()
        for row_validation in check_username:
            username_check = row_validation[0]
        validation.update(dict(validation_username = username_check))

        return jsonify(validation)

class validation(Resource):
    def get(self,username,password):
         c.execute("select count(*) from userdb where username = %s and password = %s", [(username),(password)])
         check_validation = c.fetchall()
         for row_validation in check_validation:
             validation_check = row_validation[0]
         validation = dict(validation = validation_check)
         return jsonify(validation)

class registration(Resource):
    def get(self,username,password,email,name,phone):
        registration = c.execute("insert into userdb(username,password,name,email,phone) values(%s,%s,%s,%s,%s)", [(username),(password),(name),(email),(phone)])
        status = dict(status = 1)
        return jsonify(status)

class allusers(Resource):
    def get(self):
        c.execute("select * from userdb")
        check_validation = c.fetchall()
        print(check_validation)
        for row_validation in check_validation:
            users_list = row_validation[0]
        username_list = dict(allusers = users_list)
        return jsonify(username_list)
api.add_resource(allusers, '/allusers')
api.add_resource(checkemailUsername, '/check/<email>/<username>')
api.add_resource(validation,'/checkuser/<username>/<password>')
api.add_resource(registration,'/<username>/<password>/<email>/<name>/<phone>')

if __name__ == '__main__':
     app.run(host='0.0.0.0',port='5000')
