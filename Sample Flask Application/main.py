from flask import Flask, render_template, request
import json
import requests
from requests.auth import HTTPBasicAuth
import re
from constants import URL, TOKEN
from summarizer import extract_text_from_url, summerize_text

app = Flask(__name__)

auth = HTTPBasicAuth("syedrahibreda@gmail.com", TOKEN)
headers = {
    "Accept": "application/json"
}
request_kwargs = {"headers": headers,
                  "auth": auth}


def build_response(body):
    payload = {
        'headers': "application/json",
        'status_code': 200,
        'body': body
    }
    return json.dumps(payload)

def parse_data(content):
    pattern = re.compile(r'<p>(.*?)</p>', re.DOTALL)
    matches = re.findall(pattern, content)
    combined_para = " ".join(matches)
    pattern = re.compile(r'<.*?>')
    cleaned_content = re.sub(pattern, ' ', combined_para)
    return cleaned_content


@app.get("/get_pages")
def main():
    response = requests.request(
        "GET",
        URL,
        **request_kwargs
    )
    BASE_URL = "https://pantherrr.atlassian.net/wiki"
    pages = {}
    results = json.loads(response.text).get('results', '')
    if results:
        for item in results:
            pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}
    return render_template('pages_title.html', pages=pages)


@app.route("/get_pages/<filter>")
def home(filter):
    response = requests.request(
        "GET",
        URL,
        **request_kwargs
    )
    BASE_URL = "https://pantherrr.atlassian.net/wiki"
    pages = {}
    results = json.loads(response.text).get('results', '')
    if results:
        for item in results:
            pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}
    matched_titles = []
    keywords = filter.split(" ")
    for title in pages:
        if any(keyword.lower() in title.lower() for keyword in keywords):
            matched_titles.append(title)
    page_content_merged = ""
    for title in matched_titles:
        id = pages[title]['id']
        params = {'id': id}
        url = f"https://pantherrr.atlassian.net/wiki/rest/api/content/{id}?expand=body.view"
        response = requests.request(
            "GET",
            url,
            params=params,
            **request_kwargs
        )
        page_content_merged += f"\n\n\n{json.loads(response.text)['body']['view']['value']}"
    cleaned = parse_data(page_content_merged)
    return render_template('pages_title.html', pages=cleaned)

@app.route('/result', methods=['GET', 'POST'])
def show_result():
    inp_text = ""
    input_text = extract_text_from_url(URL)
    if request.method == 'POST':
        inp_text = request.form['text']
    if inp_text:
        input_text = extract_text_from_url(inp_text)
    summary = summerize_text(input_text)
    return render_template('result_summeraze.html', summary=summary)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)
