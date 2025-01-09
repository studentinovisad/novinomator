variable "table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Controls how you are charged for read and write throughput and how you manage capacity"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "The number of read units for this table"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "The number of write units for this table"
  type        = number
  default     = null
}

variable "attributes" {
  description = "A list of attributes for the DynamoDB table"
  type = list(object({
    name      = string
    type      = string
    hash_key  = optional(bool, false)
    range_key = optional(bool, false)
  }))

  validation {
    condition     = length(var.attributes) > 0
    error_message = "At least one attribute must be defined"
  }

  validation {
    condition     = length([for a in var.attributes : a if a.hash_key]) == 1
    error_message = "Exactly one attribute must be defined as a hash key"
  }

  validation {
    condition     = length([for a in var.attributes : a if a.range_key]) <= 1
    error_message = "At most one attribute must be defined as a range key"
  }

  validation {
    condition     = length([for a in var.attributes : a.name]) == length(toset([for a in var.attributes : a.name]))
    error_message = "No duplicate attribute names are allowed"
  }
}

variable "ttl" {
  description = "The TTL configuration for the DynamoDB table"
  type = object({
    enabled        = bool
    attribute_name = optional(string, "TTL")
  })
  default = {
    enabled = false
  }
}

variable "global_secondary_indexes" {
  description = "A list of global secondary indexes for the DynamoDB table"
  type = set(object({
    name               = string
    range_key          = optional(string)
    write_capacity     = optional(number)
    read_capacity      = optional(number)
    projection_type    = string
    non_key_attributes = optional(set(string))
  }))
  default = []
}

variable "local_secondary_indexes" {
  description = "A list of local secondary indexes for the DynamoDB table"
  type = set(object({
    name               = string
    projection_type    = string
    non_key_attributes = optional(set(string))
  }))
  default = []
}
