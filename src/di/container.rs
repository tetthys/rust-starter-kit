// Minimal type-based DI container.
// Store as Arc<dyn Any + Send + Sync>, downcast on retrieval.

use parking_lot::RwLock;
use std::{
    any::{Any, TypeId},
    collections::HashMap,
    sync::Arc,
};

#[derive(Default, Clone)]
pub struct Container {
    map: Arc<RwLock<HashMap<TypeId, Arc<dyn Any + Send + Sync>>>>,
}

impl Container {
    pub fn set<T: Send + Sync + 'static>(&self, v: T) {
        self.map
            .write()
            .insert(TypeId::of::<T>(), Arc::new(v) as Arc<dyn Any + Send + Sync>);
    }

    pub fn get<T: Send + Sync + 'static>(&self) -> Option<Arc<T>> {
        let arc_any = self.map.read().get(&TypeId::of::<T>())?.clone();
        Arc::downcast::<T>(arc_any).ok()
    }
}
