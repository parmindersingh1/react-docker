

Sources
https://blog.logrocket.com/deploy-react-app-kubernetes-using-docker/

https://javaadpatel.com/building-and-deploying-react-containers/


We Can Change the envirement variable of vite at runtime when running our docker container with nginx Follow the below steps

Step-1: In .dockerignore file put your .env file so that the environment variables are not get exposed

Let's say you have following variable in .env file

VITE_API_URL=http://localhost:5000
VITE_KEY=jo2i3jkj3kj
Step-2: Create a .env.production file don't put this file in .dockerignore file.

Inside the .env.production write your env vars like this it can be prefixed with any characters like here I have prefixed them with MY_APP_

VITE_API_URL=MY_APP_API_URL
VITE_APP_KEY=MY_APP_KEY
We are using a prefix MY_APP_

Step-3: Create a env.sh file in root directory

Inside the env.sh file put this code

#!/bin/sh
for i in $(env | grep MY_APP_) // Make sure to use the prefix MY_APP_ if you have any other prefix in env.production file varialbe name replace it with MY_APP_
do
    key=$(echo $i | cut -d '=' -f 1)
    value=$(echo $i | cut -d '=' -f 2-)
    echo $key=$value
    # sed All files
    # find /usr/share/nginx/html -type f -exec sed -i "s|${key}|${value}|g" '{}' +

    # sed JS and CSS only
    find /usr/share/nginx/html -type f \( -name '*.js' -o -name '*.css' \) -exec sed -i "s|${key}|${value}|g" '{}' +
done
Step-4: Create a Dockerfile put the following code

# Stage 1: Build Image
FROM node:18-alpine as build
RUN apk add git
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2, use the compiled app, ready for production with Nginx
FROM nginx:1.21.6-alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY /nginx.conf /etc/nginx/conf.d/default.conf
COPY env.sh /docker-entrypoint.d/env.sh
RUN chmod +x /docker-entrypoint.d/env.sh
Step-5: Run below command to create a docker image

docker build -t image-name
Step-6: To Start the container use the below command to start and add env-vars at runtime

docker run --rm -p 3000:80 -e MY_APP_API_URL=api_url -e MY_APP_KEY=key image-name
When we run the above command all the env vars which start with prefix MY_APP_ it will replace the value which we provided using -e flag this is how we can add the env-vars in vite react app at runtime

Hope my solution works in your case Thank you!

Share
Improve this answer
Follow
edited Nov 10, 2023 at 14:52
answered Nov 9, 2023 at 15:46
Anas sain's user avatar
Anas sain
3122 bronze badges
Add a comment
1

I came up with a solution and published it as packages to the npm registry.

With this solution, you don't need to change any code:

// src/index.js
console.log(`API base URL is: ${import.meta.env.API_BASE_URL}.`);
It separate the build step out into two build step:

During production it will be statically replaced import.meta.env with a placeholder:

// dist/index.js
console.log(
  `API base URL is: ${"__import_meta_env_placeholder__".API_BASE_URL}.`
);
You can then run the package's CLI anywhere to replace the placeholders with your environment variables:

// dist/index.js
console.log(
  `API base URL is: ${{ API_BASE_URL: "https://httpbin.org" }.API_BASE_URL}.`
);
// > API base URL is: https://httpbin.org.
Here is the documentation site: https://iendeavor.github.io/import-meta-env/.

Feel free to provide any feedback.
