
#In PowerShell:
#setx OPENAI_API_KEY "your_api_key_here"



#The OpenAI API provides the ability to stream responses back to a client in order to allow partial results for certain requests. To achieve this, we follow the Server-sent events standard. Our official Node and Python libraries include helpers to make parsing these events simpler.
#Streaming is supported for both the Chat Completions API and the Assistants API. This section focuses on how streaming works for Chat Completions. Learn more about how streaming works in the Assistants API here.
#In Python, a streaming request looks like:


#pip install openai
#OpenAILink = r'https://platform.openai.com/docs/api-reference/authentication'

from openai import OpenAI

client = OpenAI(
  organization='org-Kla7SAa3RZoeoLTlGsaIXDPn',
  project='$PROJECT_ID',
)

stream = client.chat.completions.create(
    model="gpt-4o-mini",
    messages=[{"role": "user", "content": "Say this is a test"}],
    stream=True,
)
for chunk in stream:
    if chunk.choices[0].delta.content is not None:
        print(chunk.choices[0].delta.content, end="")