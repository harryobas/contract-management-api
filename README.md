# contract-management-api
A Sinatra based web API application for managing contracts. It provides a REST API to a DataMapper-backed model.
Furthermore, it is designed to both accept and spit data in json format.

## Token based authentication
The API utilizes a simple token based authentication mechanism for protecting certain routes as opposed to the bog-standard HTTP Basic authentication in which the user will have to send a "username" and "password" in the HTTP headers on every request, and we have to do a password comparison on every request. This isn’t fun, especially if we’re using a computationally expensive password hashing algorithm, as we should. Instead, i have opted for and implemented a basic variation of token based authentication.

Here is the procedure:

* User creates an account by sending their full name, email and password to a /users action
* The server generates and stores a very large random token, and returns it to the user
* The user sends their token with future requests to the server

## 
