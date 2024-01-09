from flask import Flask, render_template
import json
import requests
from requests.auth import HTTPBasicAuth
import re
from constants import URL, TOKEN

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
    # Filtering page id, title and page link
    BASE_URL = "https://pantherrr.atlassian.net/wiki"
    pages = {}

    results = json.loads(response.text).get('results', '')
    if results:
        for item in results:
            # print(f"id: {item['id']}, title: {item['title']}, page_url: {BASE_URL + item['_links']['webui']}")
            pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}
    return render_template('pages_title.html', pages=pages)


@app.route("/get_pages/<filter>")
def home(filter):
    response = requests.request(
        "GET",
        URL,
        **request_kwargs
    )
    # Filtering page id, title and page link
    BASE_URL = "https://pantherrr.atlassian.net/wiki"
    pages = {}

    results = json.loads(response.text).get('results', '')
    if results:
        for item in results:
            # print(f"id: {item['id']}, title: {item['title']}, page_url: {BASE_URL + item['_links']['webui']}")
            pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}

    matched_titles = []
    keywords = filter.split(" ")

    for title in pages:
        if any(keyword.lower() in title.lower() for keyword in keywords):
            matched_titles.append(title)

    # print(f"Matched keywords: {matched_titles}")
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
    # print(page_content_merged)
    cleaned = parse_data(page_content_merged)
    # print(f"\n\n\n {cleaned}")
    return render_template('pages_title.html', pages=cleaned)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)
