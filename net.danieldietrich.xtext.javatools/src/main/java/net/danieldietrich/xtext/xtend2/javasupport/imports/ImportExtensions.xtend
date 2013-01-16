package net.danieldietrich.xtext.xtend2.javasupport.imports

import org.eclipse.xtext.common.types.JvmType
import org.eclipse.xtext.common.types.JvmTypeReference

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class ImportExtensions {
  
  /**
   * Usage: jvmTypeReference.shortName(importManager) // collecting imports
   * Later: importManager.imports // output imports
   */
  def shortName(JvmTypeReference typeRef, ImportManager importManager) {
    val result = new StringBuilder()
    if (typeRef == null) {
      result.append("void");
    } else {
      importManager.appendTypeRef(typeRef, result)
    }
    result.toString
  }
  
  /**
   * Usage: jvmType.shortName(importManager) // collecting imports
   * Later: importManager.imports // output imports
   */
  def shortName(JvmType type, ImportManager importManager) {
    val result = new StringBuilder()
    if (type == null) {
      result.append("void");
    } else {
      importManager.appendType(type, result)
    }
    result.toString
  }
  
  /**
   * Usage: jvmTypeName.shortName(importManager) // collecting imports
   * Later: importManager.imports // output imports
   */
  def shortName(String type, ImportManager importManager) {
    val result = new StringBuilder()
    if (type == null) {
      result.append("void");
    } else {
      importManager.appendType(type, result)
    }
    result.toString
  }
  
}
