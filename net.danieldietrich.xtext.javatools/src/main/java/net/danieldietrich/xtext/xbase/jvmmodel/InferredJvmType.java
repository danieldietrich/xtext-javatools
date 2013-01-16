package net.danieldietrich.xtext.xbase.jvmmodel;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.InternalEObject;
import org.eclipse.xtext.common.types.JvmGenericType;

/**
 * @author Daniel Dietrich - Initial contribution and API
 */
public interface InferredJvmType<T extends EObject> extends InternalEObject, JvmGenericType {

  T getModelElement();
  
}
