package net.danieldietrich.xtext.xtend2.javasupport

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class JavaExtensions {

  def simpleName(String fqn) {
    var i = fqn.lastIndexOf("$")
    if (i != -1) {
      fqn.substring(i+1)
    } else {
      i = fqn.lastIndexOf(".")
      if (i != -1) {
        fqn.substring(i+1)
      } else {
        fqn
      }
    }
  }
  
  def packageName(String fqn) {
    val i = fqn.lastIndexOf(".")
    if (i == -1)
      ""
    else
      fqn.substring(0, i)
  }
  
  def asAttribute(String name) {
    name.toFirstLower;
  }
  
  def asGetter(String name) {
    "get" + name.toFirstUpper;
  }
  
  def asSetter(String name) {
    "set" + name.toFirstUpper;
  }
  
  def asParameter(String name) {
    name.toFirstLower;
  }
  
}
