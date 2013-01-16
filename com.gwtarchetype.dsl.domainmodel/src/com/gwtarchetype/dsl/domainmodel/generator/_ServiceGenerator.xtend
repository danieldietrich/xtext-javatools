package com.gwtarchetype.dsl.domainmodel.generator

import com.google.inject.Inject

import com.gwtarchetype.dsl.domainmodel.DomainModelExtensions
import com.gwtarchetype.dsl.domainmodel.domainModel.*

import net.danieldietrich.xtext.xtend2.javasupport.JavaExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportManager
import net.danieldietrich.xtext.xtend2.javasupport.types.TypeExtensions

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class _ServiceGenerator {
  
  // dsl specific extensions 
  @Inject extension DomainModelExtensions dmainModelExtensions
  
  // naming
  @Inject extension DomainModelNamingExtensions domainModelNamingExtensions
  
  // java support
  @Inject extension ImportExtensions importExtensions
  @Inject extension JavaExtensions javaExtensions
  @Inject extension TypeExtensions typeExtensions

  /**
   * Compile DomainModel Service -> Java @Stateless Service
   * @tags #Service
   */ 
  def compileService(Service service, ImportManager im) '''
    @«"javax.ejb.Stateless".shortName(im)»
    abstract class «service.asService.simpleName» implements «service.asServiceLocal.shortName(im)» {

      // TODO(@@dd): inject other services / resources

      «FOR op : service.operations SEPARATOR "\n"»
        «IF op.isPublic»@Override«ENDIF»
        «op.modifiers»abstract «op.type.shortName(im)» «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Service -> Java @Local Service Interface
   * @tags #ServiceLocal
   */ 
  def compileServiceLocal(Service service, ImportManager im) '''
    @«"javax.ejb.Local".shortName(im)»
    public interface «service.asServiceLocal.simpleName» {

      «FOR op : service.operations.filter(op | op.isPublic)»
      «op.type.shortName(im)» «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Service -> Java GWT RequestFactory Service Request
   * @tags #ServiceRequest
   */
  def compileServiceRequest(Service service, ImportManager im) '''
    @«"com.google.web.bindery.requestfactory.shared.Service".shortName(im)»(value = «service.asServiceLocal.shortName(im)».class, locator = «"com.gwtarchetype.server.requestfactory.EJBServiceLocator".shortName(im)».class)
    public interface «service.asServiceRequest.simpleName» extends «"com.google.web.bindery.requestfactory.shared.RequestContext".shortName(im)» {

      «FOR op : service.operations.filter(op | op.isPublic)»
      «"com.google.web.bindery.requestfactory.shared.Request".shortName(im)»<«op.type.shortName(im).box»> «op.name»(«op.params(im)»);
      «ENDFOR»
    }
  '''
  
  /**
   * Method arguments
   */
  /*private*/ def params(Operation op, ImportManager im) '''
    «FOR arg : op.params SEPARATOR ", "»«arg.parameterType.shortName(im)» «arg.name.asParameter»«ENDFOR»'''
  
  /**
   * Operation modifiers.
   */
  /*private*/ def modifiers(Operation op) {
    if (op.isPublic) {
      "public "
    } else if (op.isProtected) {
      "protected "
    } else if (op.isDefaultVisibility) {
      ""
    } else {
      throw new IllegalArgumentException("unknown visibility: " + op.visibility);
    }
  }

}
