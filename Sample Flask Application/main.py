from flask import Flask
import json
import requests
from requests.auth import HTTPBasicAuth
import re

app = Flask(__name__)

URL = "https://pantherrr.atlassian.net/wiki/api/v2/pages"
TOKEN = "ATATT3xFfGF0YRPOL6hm2-J9RSc-VJXCjVXumteip9eOaCu5oL88yVx_GAiP4BDqhjCI3cPVH_0sp8FHKo9FUyUPypZoqU80ute9G1uGPSMhgjSwXKjY7RucM55VBe3EpwQg16FEqcXkSADvuSqhdcVl_PPo6CpBno50PYhOom0EOqOxZCbSVL4=659D3F48"
auth = HTTPBasicAuth("syedrahibreda@gmail.com", TOKEN)   # replace email id
headers = {
    "Accept": "application/json"
}


def build_response(body):
    payload = {
        'headers': "application/json",
        'status_code': 200,
        'body': body
    }
    return json.dumps(payload)

def parse_data(content):
    # extract content within <p> </p>
    pattern = re.compile(r'<p>(.*?)</p>', re.DOTALL)
    matches = re.findall(pattern, content)
    combined_para = " ".join(matches)
    # remove remaining content within <html tag>
    pattern = re.compile(r'<.*?>')
    cleaned_content = re.sub(pattern, ' ', combined_para)
    return cleaned_content


@app.get("/get_pages")
def main():
    response = requests.request(
        "GET",
        URL,
        headers=headers,
        auth=auth
    )
    # Filtering page id, title and page link
    BASE_URL = "https://pantherrr.atlassian.net/wiki"  # replace <your_registered_name>

    pages = {}

    for item in json.loads(response.text)['results']:
        print(f"id: {item['id']}, title: {item['title']}, page_url: {BASE_URL + item['_links']['webui']}")
        pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}

    return build_response(pages)


@app.route("/get_pages/<filter>")
def home(filter):
    print(filter.split(" "))
    response = requests.request(
        "GET",
        URL,
        headers=headers,
        auth=auth
    )
    # Filtering page id, title and page link
    BASE_URL = "https://pantherrr.atlassian.net/wiki"  # replace <your_registered_name>

    pages = {}

    for item in json.loads(response.text)['results']:
        print(f"id: {item['id']}, title: {item['title']}, page_url: {BASE_URL + item['_links']['webui']}")
        pages[item['title']] = {'id': item['id'], 'link': BASE_URL + item['_links']['webui']}

        matched_titles = []
        keywords = filter.split(" ")

        for title in pages:
            if any(keyword.lower() in title.lower() for keyword in keywords):
                matched_titles.append(title)

    print(f"Matched keywords: {matched_titles}")

    print("\nBefore preprocessing!!!")
    page_content_merged = ""

    for title in matched_titles:
        id = pages[title]['id']
        params = {'id': id}
        url = f"https://pantherrr.atlassian.net/wiki/rest/api/content/{id}?expand=body.view"
        response = requests.request(
            "GET",
            url,
            headers=headers,
            auth=auth,
            params=params
        )
        page_content_merged += f"\n\n\n{json.loads(response.text)['body']['view']['value']}"

    print(page_content_merged)

    print("\nAfter preprocessing!!!")

    cleaned = parse_data(page_content_merged)

    print(f"\n\n\n {cleaned}")

    return build_response(cleaned)
