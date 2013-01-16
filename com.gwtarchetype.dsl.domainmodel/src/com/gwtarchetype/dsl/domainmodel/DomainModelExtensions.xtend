package com.gwtarchetype.dsl.domainmodel

import com.gwtarchetype.dsl.domainmodel.domainModel.*

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.common.types.JvmDeclaredType

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class DomainModelExtensions {
	
	/**
	 * computes the basePackage of the DomainModel (@see DomainModel.xtext)
	 */
	def String basePackage(Object o) {
	   switch(o) {
      DomainModel : o.basePackage
      EObject : basePackage(o.eContainer)
      default: ""
    }
	}
	
	/**
	 * computes the qualified name if its 
	 *  a PackageDeclaration, an Entity or a JvmDeclaredType
	 * returns null otherwise
	 */
	def String packageName(Object o) {
		switch(o) {
			PackageDeclaration : concatPath(packageName(o.eContainer), o.name)
			EObject : packageName(o.eContainer)
			JvmDeclaredType : o.packageName
			default: ""
		}
	}
	
	/*private*/ def concatPath(String prefix, String suffix) {
		if (prefix.nullOrEmpty) 
			suffix 
		else 
			prefix + "." + suffix
	}
	
	// TODO(@@dd): because enums don't support null values in conjunction with optional rules, helpers for hard coded string are needed:
	
	def isDefaultVisibility(OperationWithQuery op) {
    op.visibility.isDefaultVisibility
  }
  def isDefaultVisibility(Operation op) {
    op.visibility.isDefaultVisibility
  }
  /*private*/ def isDefaultVisibility(String visibility) {
    "default".equals(visibility)
  }
  
  def isProtected(OperationWithQuery op) {
    op.visibility.isProtected
  }
  def isProtected(Operation op) {
    op.visibility.isProtected
  }
  /*private*/ def isProtected(String visibility) {
    "protected".equals(visibility)
  }

  def isPublic(OperationWithQuery op) {
    op.visibility.isPublic
  }
  def isPublic(Operation op) {
    op.visibility.isPublic
  }
  /*private*/ def isPublic(String visibility) {
    visibility == null
  }
  
}
