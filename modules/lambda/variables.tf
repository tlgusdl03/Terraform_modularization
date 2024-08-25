variable "lambda_function_name" {
  description = "Name <region>-<env>-<serviceName>-<resourceType>-<details>(ex:primary-dev-ecom-lambda-scheduling)"
  type = string
}

variable "source_path" {
  description = "Path of source code for lambda"
  type = string
}

variable "lambda_function_timeout" {
  description = "Timeout of lambda_function"
  type = number
}