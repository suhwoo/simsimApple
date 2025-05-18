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
    data = request.get_json()
    if not data:
        return jsonify({"success": False, "message": "요청 본문이 비어있습니다."}), 400

    username = data.get('username')
    password = data.get('password')

    if not username or not password:
        return jsonify({"success": False, "message": "사용자 이름과 비밀번호를 모두 입력해주세요."}), 400

    if username in users and users[username] == password:
        # 실제 앱에서는 여기에 토큰 생성 등의 로직 추가
        return jsonify({"success": True, "message": "로그인 성공!"})
    else:
        return jsonify({"success": False, "message": "잘못된 사용자 이름 또는 비밀번호입니다."})

if __name__ == '__main__':
    # 다른 포트 충돌을 피하기 위해 5001 포트 사용 (기본 Flask 포트는 5000)
    # 실제 다른 서비스와 포트가 겹치지 않는지 확인 필요
    app.run(debug=True, port=5001) 