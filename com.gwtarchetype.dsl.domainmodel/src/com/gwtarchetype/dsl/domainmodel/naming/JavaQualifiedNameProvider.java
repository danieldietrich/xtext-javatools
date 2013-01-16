package com.gwtarchetype.dsl.domainmodel.naming;

import org.eclipse.xtext.common.types.JvmGenericType;
import org.eclipse.xtext.naming.DefaultDeclarativeQualifiedNameProvider;
import org.eclipse.xtext.naming.IQualifiedNameConverter;
import org.eclipse.xtext.naming.QualifiedName;

import com.google.inject.Inject;

/**
 * Used in conjunction with the inferred JVM model.<br>
 * Read {@link http://www.eclipse.org/Xtext/documentation/2_0_0/199c-xbase-inferred-type.php}.
 * 
 * @author Daniel Dietrich
 * @see com.gwtarchetype.dsl.domainmodel.jvmmodel.DomainModelJvmModelInferrer
 */
public class JavaQualifiedNameProvider extends DefaultDeclarativeQualifiedNameProvider {

  @Inject
  private IQualifiedNameConverter converter;

  QualifiedName qualifiedName(JvmGenericType type) {
    return converter.toQualifiedName(type.getQualifiedName());
  }
}
