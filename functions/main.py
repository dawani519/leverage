from flask import Flask, request, jsonify
from firebase_admin import credentials, initialize_app, firestore
import requests

# Initialize Flask app
app = Flask(__name__)

# Initialize Firebase Admin SDK
cred = credentials.Certificate("C:\\Users\\user\\Documents\\leverage\\functions\\leverage-eaf34-3904e3a57683.json")  # Replace with your credentials file path
initialize_app(cred)
db = firestore.client()

@app.route('/verify-payment', methods=['GET'])
def verify_payment():
    reference = request.args.get('reference')  # Reference from the frontend

    if not reference:
        return jsonify({"status": "error", "message": "No reference provided"}), 400

    # Paystack API call for verification
    headers = {
        'Authorization': 'Bearer YOUR_PAYSTACK_SECRET_KEY'  # Replace with your Paystack secret key
    }
    response = requests.get(f'https://api.paystack.co/transaction/verify/{reference}', headers=headers)

    if response.status_code == 200:
        result = response.json()
        if result['status'] and result['data']['status'] == 'success':
            amount_paid = result['data']['amount'] / 100  # Convert from kobo to NGN
            customer_email = result['data']['customer']['email']

            # Query Firestore securely
            user_query = db.collection('users').where('email', '==', customer_email).limit(1)
            user_docs = user_query.stream()
            user_doc = next(user_docs, None)

            if user_ref:
                user_doc = user_ref[0]
                user_id = user_doc.id

                user_ref = db.collection('users').document(user_id)
                user_ref.set({
                    'wallet_balance': firestore.Increment(amount_paid),
                    'customerEmail': customer_email
                }, merge=True)

                return jsonify({
                    "status": "success",
                    "message": "Transaction verified",
                    "amount_paid": amount_paid
                }), 200
            else:
                return jsonify({"status": "error", "message": "User not found"}), 404
        else:
            return jsonify({"status": "error", "message": "Payment not successful"}), 400
    else:
        error_message = response.json().get('message', 'Unknown error')
        return jsonify({"status": "error", "message": f"Error verifying transaction: {error_message}"}), 500

if __name__ == '__main__':
    app.run(debug=True)
