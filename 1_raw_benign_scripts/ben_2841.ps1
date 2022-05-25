# 2019-23-11 - Added Powershell Script. See the other file.
# download all PlaysTv videos of a user
# To find the user id, navigate to the your profile while logged in (IMPORTANT!)
# View source of the page, In the <html> tag there's data-conf attribute.
# The json in there will have the user id under [login_user.id]
from re import sub
from json import load
from urllib.request import urlretrieve, urlopen


def safe_title(index, title):
    only_chars = sub(r'[^\w]+', '_', title).strip("_")
    return f"{index} - {only_chars[:30]}.mp4"


def get_playstv_videos(user_id):
    last_id = ""
    items = []
    while last_id != None:
        batch = load(urlopen(
            f"https://plays.tv/playsapi/feedsys/v1/userfeed/{user_id}/uploaded?limit=200&filter=&lastId={last_id}"))
        items.extend(batch["items"])
        last_id = batch["lastId"]
    print(len(items))

    for index, item in enumerate(items, start=1):
        try:
            filename, url = safe_title(
                index, item["description"]), item["downloadUrl"]
            print(f"Downloading {filename} from {url}")
            urlretrieve(url, filename)
        except Exception as e:
            print(f"Error downloading {filename} from {url}")
            print(e)


if __name__ == "__main__":
    get_playstv_videos("<playstv userid>")
