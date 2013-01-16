package net.danieldietrich.xtext.xtend2.javasupport.types

import org.eclipse.xtext.common.types.JvmParameterizedTypeReference
import org.eclipse.xtext.common.types.JvmTypeReference

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class TypeExtensions {
		
  def isVoid(JvmTypeReference type) {
    type == null || "void".equalsIgnoreCase(type.qualifiedName)
  }

  def isNumber(JvmTypeReference type) {
    newArrayList("byte", "double", "float", "int", "long", "short").contains(type?.qualifiedName.toLowerCase)
  }

  def isList(JvmParameterizedTypeReference type) {
    // TODO(@dd): consider inheritance
    type != null && type.qualifiedName.startsWith("java.util.List")
  }
  
  def box(JvmTypeReference type) {
    box(type?.qualifiedName)
  }
  
  def box(String qn) {
    switch (qn) {
      case "boolean" : "Boolean"
      case "byte" : "Byte"
      case "double" : "Double"
      case "float" : "Float"
      case "int" : "Integer"
      case "long" : "Long"
      case "short" : "Short"
      case "void" : "Void"
      case null : "Void"
      default : qn
    }
  }
  
  def unbox(JvmTypeReference type) {
    type?.qualifiedName.unbox
  }
  
  def unbox(String qn) {
    switch (qn) {
      case "Boolean" : "boolean"
      case "Byte" : "byte"
      case "Double" : "double"
      case "Float" : "float"
      case "Integer" : "int"
      case "Long" : "long"
      case "Short" : "short"
      case "Void" : "void"
      case null : "void"
      default : qn
    }
  }
	  
}
