#!/bin/bash
u+x

terraform {
    required_providers {
            aws = {
	                source = "hashicorp/aws"
			            version = "5.8.1"
				            }
					        }
						}

						provider "aws" {
						    region = "us-east-1"
						        profile = "Helen"
							    # Configuration Options
							    }

							    module "tgw" {
							      source  = "terraform-aws-modules/transit-gateway/aws"
							        version = "~> 2.0"

								  name        = "my-tgw"
								    description = "My TGW shared with several other AWS accounts"

								    # Transit Gateway Creation
								    resource "aws_ec2_transit_gateway" "this" {
								     
								      description        = var.transit_gateway_description
								        
									 amazon_side_asn    = var.amazon_side_asn
									   
									    auto_accept_shared_attachments = var.auto_accept_shared_attachments
									     
									      default_route_table_association = var.default_route_table_association
									       
									        default_route_table_propagation = var.default_route_table_propagation
										 
										  tags                         = var.tags
										  }

										    enable_auto_accept_shared_attachments = true

										    # Transit Gateway Attachments
										      vpc_attachments = {
										          vpc = {
											        vpc_id       = module.vpc.vpc_id
												      subnet_ids   = module.vpc.private_subnets
												            dns_support  = true
													          ipv6_support = true

														  # Route Tables and Associations
														  resource "aws_ec2_transit_gateway_route_table_association" "this" {
														   for_each = var.vpc_attachments

														     transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
														       transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
														       }

														       # Security and Access Control
														       resource "aws_iam_role" "transit_gateway_role" {
														         
															    name = "transit-gateway-role"

															     assume_role_policy = jsonencode({
															        
																   Version = "2012-10-17"
																      
																         Statement = [{
																	      
																	           Action = "sts:AssumeRole"
																		         
																			      Effect = "Allow"
																			           
																				        Principal = {
																					        
																						       Service = "ec2.amazonaws.com"
																						           
																							        }
																								   
																								      }]
																								       
																								        })

																									}



																									resource "aws_iam_policy" "transit_gateway_policy" {
																									 
																									    name = "transit-gateway-policy"
																									      
																									       

																									          policy = jsonencode({
																										     
																										          Version = "2012-10-17"
																											     
																											          Statement = [{
																												       
																												              Action = [
																													             
																														              "ec2:CreateTransitGateway",
																															             
																																              "ec2:DeleteTransitGateway",
																																	             
																																		              "ec2:DescribeTransitGateways",
																																			             
																																				              "ec2:AttachTransitGatewayVpcAttachment",
																																					             
																																						              "ec2:DetachTransitGatewayVpcAttachment"
																																							          
																																								         ]
																																									      
																																									             Effect = "Allow"
																																										          
																																											         Resource = "*"
																																												    
																																												         }]
																																													  
																																													     })

																																													       }

																																													        

																																														resource "aws_iam_role_policy_attachment" "transit_gateway_attachment" {
																																														 
																																														     role       = aws_iam_role.transit_gateway_role.name
																																														       
																																														           policy_arn = aws_iam_policy.transit_gateway_policy.arn

																																															   }

																																															   # Tagging
																																															   variable "tags" {
																																															    
																																															     description = "Tags to be applied to all resources"
																																															      
																																															       type        = map(string)
																																															         
																																																  default     = {
																																																      
																																																          Name        = "TransitGateway"
																																																	     
																																																	         Environment = "dev"
																																																		    
																																																		        Project     = "MyProject"
																																																			  
																																																			     }

																																																			     }

																																																			     # Variables and Outputs
																																																			     variable "transit_gateway_description" {
																																																			       
																																																			         description = "Description for the Transit Gateway"
																																																				  
																																																				    type        = string

																																																				    }



																																																				    variable "amazon_side_asn" {
																																																				     
																																																				       description = "Amazon side ASN for the Transit Gateway"
																																																				        
																																																					  type        = number

																																																					  }



																																																					  variable "auto_accept_shared_attachments" {
																																																					   
																																																					     description = "Auto accept shared attachments"
																																																					      
																																																					        type        = string
																																																						 
																																																						   default     = "disable"

																																																						   }



																																																						   variable "default_route_table_association" {
																																																						     
																																																						       description = "Default route table association"
																																																						        
																																																							  type        = string
																																																							    
																																																							      default     = "disable"

																																																							      }

																																																							      variable "default_route_table_propagation" {
																																																							       
																																																							         description = "Default route table propagation"
																																																								  
																																																								    type        = string
																																																								      
																																																								        default     = "disable"

																																																									}



																																																									variable "vpc_attachments" {
																																																									 
																																																									   description = "VPCs to attach to the Transit Gateway"
																																																									    
																																																									      type = map(object({
																																																									          
																																																										      vpc_id      = string
																																																										          
																																																											      subnet_ids  = list(string)
																																																											         
																																																												     dns_support = string
																																																												        
																																																													    ipv6_support = string
																																																													      
																																																													      }))

																																																													      }



																																																													      variable "create_route_table" {
																																																													       
																																																													         description = "Flag to create route table"
																																																														  
																																																														    type        = bool
																																																														      
																																																														        default     = true

																																																															}



																																																															variable "custom_routes" {
																																																															  
																																																															    description = "Custom routes for the Transit Gateway route table"
																																																															      
																																																															        type = map(object({
																																																																    
																																																																        destination_cidr_block = string
																																																																	  
																																																																	      attachment_key         = string
																																																																	       
																																																																	        }))

																																																																		}

																																																																		# Output
																																																																		output "transit_gateway_id" {
																																																																		  
																																																																		    value = aws_ec2_transit_gateway.this.id

																																																																		    }



																																																																		    output "attachment_ids" {
																																																																		     
																																																																		       value = [for attachment in aws_ec2_transit_gateway_vpc_attachment.this : attachment.id]

																																																																		       }



																																																																		       output "route_table_id" {
																																																																		         
																																																																			   value = aws_ec2_transit_gateway_route_table.this[0].id
																																																																			   }


																																																																			   # Documentation
																																																																			   module "tgw" {
																																																																			     source  = "terraform-aws-modules/transit-gateway/aws"
																																																																			       version = "~> 2.0"

																																																																			         name        = "my-tgw"
																																																																				   description = "My TGW shared with several other AWS accounts"

																																																																				     enable_auto_accept_shared_attachments = true

																																																																				       vpc_attachments = {
																																																																				           vpc = {
																																																																					         vpc_id       = module.vpc.vpc_id
																																																																						       subnet_ids   = module.vpc.private_subnets
																																																																						             dns_support  = true
																																																																							           ipv6_support = true

																																																																								         tgw_routes = [
																																																																									         {
																																																																										           destination_cidr_block = "30.0.0.0/16"
																																																																											           },
																																																																												           {
																																																																													             blackhole = true
																																																																														               destination_cidr_block = "40.0.0.0/20"
																																																																															               }
																																																																																             ]
																																																																																	         }
																																																																																		   }

																																																																																		     ram_allow_external_principals = true
																																																																																		       ram_principals = [307990089504]

																																																																																		         tags = {
																																																																																			     Purpose = "tgw-complete-example"
																																																																																			       }
																																																																																			       }

																																																																																			       module "vpc" {
																																																																																			         source  = "terraform-aws-modules/vpc/aws"
																																																																																				   version = "~> 3.0"

																																																																																				     name = "my-vpc"

																																																																																				       cidr = "10.10.0.0/16"

																																																																																				         azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
																																																																																					   private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]

																																																																																					     enable_ipv6                                    = true
																																																																																					       private_subnet_assign_ipv6_address_on_creation = true
																																																																																					         private_subnet_ipv6_prefixes                   = [0, 1, 2]
																																																																																						 }
