from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # 모든 도메인에서의 요청을 허용 (개발용)

# 간단한 사용자 정보 (실제 앱에서는 DB 사용)
users = {
    "testuser": "password123"
}

@app.route('/login', methods=['POST'])
def login():
    print("\n--- Request received at /login ---")
    data = request.get_json()
    
    if not data:
        print("[SERVER LOG] Error: Request body is empty.")
        return jsonify({"success": False, "message": "요청 본문이 비어있습니다."}), 400
    
    print(f"[SERVER LOG] Received data: {data}")

    username = data.get('username')
    password = data.get('password')
    print(f"[SERVER LOG] Extracted username: '{username}', password: '{password}'")

    if not username or not password:
        print("[SERVER LOG] Error: Username or password missing.")
        return jsonify({"success": False, "message": "사용자 이름과 비밀번호를 모두 입력해주세요."}), 400

    if username in users and users[username] == password:
        print(f"[SERVER LOG] Login successful for user: '{username}'")
        # 실제 앱에서는 여기에 토큰 생성 등의 로직 추가
        return jsonify({"success": True, "message": "로그인 성공!"})
    else:
        print(f"[SERVER LOG] Login failed for user: '{username}'. Invalid credentials.")
        return jsonify({"success": False, "message": "잘못된 사용자 이름 또는 비밀번호입니다."}), 401 # HTTP 401 for unauthorized

if __name__ == '__main__':
    print("--- Starting Flask Server ---")
    print("Login server running on http://127.0.0.1:5001")
    print("Registered users:", users)
    print("Send POST requests to /login with JSON body: {'username': 'your_user', 'password': 'your_password'}")
    print("-----------------------------")
    # 다른 포트 충돌을 피하기 위해 5001 포트 사용 (기본 Flask 포트는 5000)
    # 실제 다른 서비스와 포트가 겹치지 않는지 확인 필요
    app.run(debug=True, port=5001) 