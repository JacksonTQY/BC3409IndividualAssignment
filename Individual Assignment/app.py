from flask import Flask
from flask import request, render_template
import joblib

app = Flask(__name__) 

@app.route("/", methods=["GET","POST"])
def index():
    if request.method == "POST":
        income = request.form.get("income")
        age = request.form.get("age")
        loan = request.form.get("loan")
        print("income, age, loan:", income, age, loan)
        model = joblib.load("MLP")
        pred = model.predict([[float(income), float(age), float(loan)]])
        print(pred)
        s = "The predicted default is: " + str(pred)
        
        return render_template("index.html", result=s)
    else:
        return render_template("index.html", result="Please enter some values")

if __name__ == "__main__": # only if it's your program, then run
    app.run()



