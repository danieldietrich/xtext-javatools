package com.gwtarchetype.dsl.domainmodel.jvmmodel
 
import com.google.inject.Inject
import com.gwtarchetype.dsl.domainmodel.DomainModelExtensions
import com.gwtarchetype.dsl.domainmodel.domainModel.*

import net.danieldietrich.xtext.xbase.jvmmodel.*

import org.eclipse.xtext.xbase.jvmmodel.*
import org.eclipse.emf.ecore.*
import org.eclipse.xtext.common.types.*
import java.util.*

import static org.eclipse.xtext.EcoreUtil2.*

// TODO(@@dd): Update DomainModelJvmModelInferrer (with Xtext 2.1.0)
// @see https://bugs.eclipse.org/bugs/show_bug.cgi?id=356977
class DomainModelJvmModelInferrer implements IJvmModelInferrer {

  @Inject InferredJvmTypeFactory inferredTypesFactory
  @Inject TypesFactory typesFactory
  
  @Inject extension IJvmModelAssociator jvmModelAssociator
  @Inject extension DomainModelExtensions domainModelExtensions

  override List<JvmDeclaredType> inferJvmModel(EObject sourceObject) {
    sourceObject.disassociate
    transform( sourceObject ).toList
  }
  
  // DomainModel
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(DomainModel model) {
    model.elements.map(e | transform(e)).flatten
  }
  
  // PackageDeclaration
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(PackageDeclaration packageDecl) {
    packageDecl.elements.map(e | transform(e)).flatten
  }

  // Entity
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(Entity entity) {
    val clazz = inferredTypesFactory.createInferredJvmType(entity, entity.packageName, entity.name)
    entity.associatePrimary(clazz)
    clazz.visibility = JvmVisibility::PUBLIC
    if (entity.superType != null) {
      clazz.superTypes += cloneWithProxies(entity.superType)
    }
    // TODO(@@dd): currently not working
//    for(f : entity.features) {
//      transform(f, clazz)
//    }
    newArrayList(clazz as JvmDeclaredType)    
  }
  
  // Service
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(Service service) {
    val clazz = inferredTypesFactory.createInferredJvmType(service, service.packageName, service.name)
    service.associatePrimary(clazz)
    clazz.visibility = JvmVisibility::PUBLIC
    if (service.superType != null) {
      clazz.superTypes += cloneWithProxies(service.superType)
    }
    for(op : service.operations) {
      transform(op, clazz)
    }
    newArrayList(clazz as JvmDeclaredType)    
  }
  
  // Value
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(Value value) {
    val clazz = inferredTypesFactory.createInferredJvmType(value, value.packageName, value.name)
    value.associatePrimary(clazz)
    clazz.visibility = JvmVisibility::PUBLIC
    if (value.superType != null) {
      clazz.superTypes += cloneWithProxies(value.superType)
    }
//    for(p : value.properties) {
//      transform(p, clazz)
//    }
    newArrayList(clazz as JvmDeclaredType)    
  }
  
  // Import
  /*private*/ def dispatch Iterable<JvmDeclaredType> transform(Import importDecl) {
    emptyList
  }
  
  // Property
  /*private*/ def dispatch void transform(Property property, InferredJvmType type) {
    val jvmField = typesFactory.createJvmField
    jvmField.simpleName = property.name
    jvmField.type = cloneWithProxies(property.type)
    jvmField.visibility = JvmVisibility::PRIVATE
//    jvmField.declaringType = type
    type.members += jvmField
    property.associatePrimary(jvmField)
    
    val jvmGetter = typesFactory.createJvmOperation
    jvmGetter.simpleName = "get" + property.name.toFirstUpper
    jvmGetter.returnType = cloneWithProxies(property.type)
    jvmGetter.visibility = JvmVisibility::PUBLIC
//    jvmGetter.declaringType = type
    type.members += jvmGetter
    property.associatePrimary(jvmGetter)
    
    val jvmSetter = typesFactory.createJvmOperation
    jvmSetter.simpleName = "set" + property.name.toFirstUpper
    val parameter = typesFactory.createJvmFormalParameter
    parameter.name = property.name.toFirstUpper
    parameter.parameterType = cloneWithProxies(property.type)
    jvmSetter.visibility = JvmVisibility::PUBLIC
    jvmSetter.parameters += parameter
//    jvmSetter.declaringType = type
    type.members += jvmSetter
    property.associatePrimary(jvmSetter)
  }

  // OperationWithQuery
  /*private*/ def dispatch void transform(OperationWithQuery operation, InferredJvmType type) {
    val jvmOperation = typesFactory.createJvmOperation
    jvmOperation.simpleName = operation.name
    jvmOperation.returnType = cloneWithProxies(operation.type)
    jvmOperation.parameters.addAll(operation.params.map(p|cloneWithProxies(p))) 
    jvmOperation.visibility = operation.visibility.toJvmVisibility
    jvmOperation.declaringType = type
    type.members += jvmOperation
    operation.associatePrimary(jvmOperation)
  }

  // Operation
  /*private*/ def dispatch void transform(Operation operation, InferredJvmType type) {
    val jvmOperation = typesFactory.createJvmOperation
    jvmOperation.simpleName = operation.name
    jvmOperation.returnType = cloneWithProxies(operation.type)
    jvmOperation.parameters.addAll(operation.params.map(p|cloneWithProxies(p))) 
    jvmOperation.visibility = operation.visibility.toJvmVisibility
    jvmOperation.declaringType = type
    type.members += jvmOperation
    operation.associatePrimary(jvmOperation)
  }

  // Visibility  
  /*private*/ def toJvmVisibility(String visibility) {
    if (visibility == null) {
      return JvmVisibility::PUBLIC
    } else if (visibility.equals("default")) {
      return JvmVisibility::DEFAULT
    } else if (visibility.equals("protected")) {
      return JvmVisibility::PROTECTED
    } else {
      throw new IllegalStateException("unknown visibility: " + visibility);
    }
  }
   
}
