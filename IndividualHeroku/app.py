#!/usr/bin/env python
# coding: utf-8

# In[11]:
from flask import Flask
from flask import request, render_template
import joblib
from scipy import stats
import pandas as pd

app = Flask(__name__) 

@app.route("/", methods=["GET","POST"])
def index():
    if request.method == "POST":
        income = float(request.form.get("income"))
        age = float(request.form.get("age"))
        loan = float(request.form.get("loan"))
        print("income, age, loan:", income, age, loan)
        
        model = joblib.load("XGB")
        pred = model.predict([[float(income), float(age), float(loan)]])
        print(pred)
        s = "The predicted default is: " + str(pred)
        
        return render_template("index.html", result=s)
    else:
        return render_template("index.html", result="Please enter some values")

if __name__ == "__main__": # only if it's your program, then run
    app.run()


# In[ ]:




