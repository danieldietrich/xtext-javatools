package com.gwtarchetype.dsl.domainmodel.generator

import com.google.inject.Inject

import com.gwtarchetype.dsl.domainmodel.domainModel.*

import net.danieldietrich.xtext.xtend2.javasupport.JavaGenerator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.generator.IFileSystemAccess
import static extension org.eclipse.xtext.xtend2.lib.ResourceExtensions.*


// TODO(@@dd):
// o generate to slots ../fysell.comEjb/ & ../fysell.comWeb/
// o generation gap pattern (generate to src, src-gen, src-once)
// o create more generators (domain model, ui, etc.)
// o specify global properties like persistenceUnitName(String), singleRequestFactory(boolean)


/**
 * @author Daniel Dietrich - Initial contribution and API
 */
class DomainModelGenerator implements IGenerator {
  
  // naming extensions
  @Inject extension DomainModelNamingExtensions domainModelNamingExtensions
  
  // generator parts
  @Inject extension _EntityGenerator entityGenerator
  @Inject extension _ServiceGenerator serviceGenerator
  @Inject extension _ValueGenerator valueGenerator
  
  // java support
  @Inject extension JavaGenerator javaGenerator
  
  /**
   * Entry point.
   * @tags #EntryPoint
   * @see IGenerator#doGenerate(Resource, IFileSystemAccess)
   */
  override doGenerate(Resource resource, IFileSystemAccess fsa) {
    
    val clientSlot = "client-gen";
    val serverSlot = "server-gen";
    
    val clientConverter = newHashMap
      .add(typeof(Entity), [e | e.asEntityProxy])
      .add(typeof(Value), [v | v.asValueProxy])

    val serverConverter = newHashMap
      .add(typeof(Entity), [e | e.asEntity])
      .add(typeof(Value), [v | v.asValue])
    
    // -- DSL:Entity
    for (e : resource.allContentsIterable.filter(typeof(Entity))) {
      e.generate(fsa, serverSlot, e.asEntity, serverConverter, [_e,im | _e.compileEntity(im)])
      e.generate(fsa, serverSlot, e.asDAO, serverConverter, [_e,im | _e.compileDAO(im)])
      e.generate(fsa, serverSlot, e.asDAOLocal, serverConverter, [_e,im | _e.compileDAOLocal(im)])
      e.generate(fsa, clientSlot, e.asEntityProxy, clientConverter, [_e,im | _e.compileEntityProxy(im)])
      e.generate(fsa, clientSlot, e.asEntityRequest, clientConverter, [_e,im | _e.compileEntityRequest(im)])
    }
    
    // -- DSL:Service
    for (s : resource.allContentsIterable.filter(typeof(Service))) {
      s.generate(fsa, serverSlot, s.asService, serverConverter, [_s,im | _s.compileService(im)])
      s.generate(fsa, serverSlot, s.asServiceLocal, serverConverter, [_s,im | _s.compileServiceLocal(im)])
      s.generate(fsa, clientSlot, s.asServiceRequest, clientConverter, [_s,im | _s.compileServiceRequest(im)])
    }
    
    // -- DSL:Value
    for (v : resource.allContentsIterable.filter(typeof(Value))) {
      v.generate(fsa, serverSlot, v.asValue, serverConverter, [_v,im | _v.compileValue(im)])
      v.generate(fsa, clientSlot, v.asValueProxy, clientConverter, [_v,im | _v.compileValueProxy(im)])
    }
    
// TODO(@@dd): generate EntityRequestFactory, generated ServiceRequestFactory
  }
  
}
