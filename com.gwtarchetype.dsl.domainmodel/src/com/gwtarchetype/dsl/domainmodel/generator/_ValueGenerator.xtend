package com.gwtarchetype.dsl.domainmodel.generator

import com.google.inject.Inject

import com.gwtarchetype.dsl.domainmodel.domainModel.*

import net.danieldietrich.xtext.xtend2.javasupport.JavaExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportExtensions
import net.danieldietrich.xtext.xtend2.javasupport.imports.ImportManager

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class _ValueGenerator {
  
  // naming
  @Inject extension DomainModelNamingExtensions domainModelNamingExtensions
  
  // java support
  @Inject extension ImportExtensions importExtensions
  @Inject extension JavaExtensions javaExtensions

  /**
   * Compile DomainModel Value -> Java Bean
   * @tags #Value
   */ 
  def compileValue(Value value, ImportManager im) '''
    public class «value.asValue.simpleName»«IF value.superType != null» extends «value.superType.shortName(im)»«ENDIF» {
    
      «FOR attr : value.properties»
      private «attr.type.shortName(im)» «attr.name.asAttribute»;
      «ENDFOR»
    
      «FOR attr : value.properties SEPARATOR "\n"»
      public «attr.type.shortName(im)» «attr.name.asGetter»() {
        return «attr.name.asAttribute»;
      }
      public void «attr.name.asSetter»(«attr.type.shortName(im)» «attr.name.asAttribute») {
        this.«attr.name.asAttribute» = «attr.name.asAttribute»;
      }
      «ENDFOR»
    }
  '''
  
  /**
   * Compile DomainModel Value -> Java GWT RequestFactory ValueProxy
   * @tags #ValueProxy
   */
  def compileValueProxy(Value value, ImportManager im) '''
    @«"com.google.web.bindery.requestfactory.shared.ProxyFor".shortName(im)»(value = «value.asValue.shortName(im)».class)
    public interface «value.asValueProxy.simpleName» extends «"com.google.web.bindery.requestfactory.shared.ValueProxy".shortName(im)» {
    
      «FOR attr : value.properties SEPARATOR "\n"»
      «attr.type.shortName(im)» «attr.name.asGetter»();
      void «attr.name.asSetter»(«attr.type.shortName(im)» «attr.name.asAttribute»);
      «ENDFOR»
    }
  '''

}
