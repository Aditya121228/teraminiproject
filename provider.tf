terraform{
    
        required_providers{
            aws={
                source= "hashicorp/aws"
                version= "~>5.0"
             }
    }
}

#congiguration
provider "aws"{
  region="ap-south-1"
  access_key = ""
  secret_key = ""
}