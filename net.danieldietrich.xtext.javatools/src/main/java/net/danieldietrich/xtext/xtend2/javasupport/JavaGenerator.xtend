package net.danieldietrich.xtext.xtend2.javasupport

import com.google.inject.Inject

import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportManager

import java.util.Map

import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.generator.IFileSystemAccess

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class JavaGenerator {
	
	@Inject extension JavaExtensions javaExtensions
  
  /**
   * Generic java class generator which
   * - compiles the class
   * - organizes imports
   * - writes file to disk
   * 
   * The class file has a common structure which will be generated
   * automatically. Only the compiler of the body of the class
   * has to be specified.
   */
  def <T extends EObject, R extends CharSequence> generate(T node, IFileSystemAccess fsa, String fqn, Map<Class<?>, (Object)=>String> converter, (T,ImportManager)=>R compiler) {
    fsa.generateFile(fqn.asJavaFileName, node.compile(fqn.packageName, converter, compiler))
  }
  
  /**
   * Same as above - but using slots for writing files.
   */
  def <T extends EObject, R extends CharSequence> generate(T node, IFileSystemAccess fsa, String slot, String fqn, Map<Class<?>, (Object)=>String> converter, (T,ImportManager)=>R compiler) {
    fsa.generateFile(fqn.asJavaFileName, slot, node.compile(fqn.packageName, converter, compiler))
  }
  
  /**
   * Generic java class compiler which organizes imports
   */
  /*private*/ def <T extends EObject, R extends CharSequence> compile(T node, String packageName, Map<Class<?>, (Object)=>String> converter, (T,ImportManager)=>R compiler) '''
    /**
     * generated
     */
    «val importManager = new ImportManager(packageName, converter)»
    «val body = compiler.apply(node, importManager)»
    «IF packageName != null»
      package «packageName»;
    «ENDIF»
    
    «FOR i : importManager.imports»
      import «i»;
    «ENDFOR»
    
    «body»
  '''
  
  /**
   * Add transformation to an existing 'converter' Map.
   * Need param <T> for typesafe transformation.
   */
  def <T extends Object> add(java.util.Map<Class<?>,(Object)=>String> map, Class<T> type, (T)=>String transformation) {
    map.put(type, transformation as (Object)=>String); // need cast for generated code(!)
    map
  }
  
  /*private*/ def asJavaFileName(String fqn) {
    fqn.replace(".", "/") + ".java"
  }
  
}
