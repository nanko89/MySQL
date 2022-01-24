package implementations;

import interfaces.AbstractQueue;

import java.util.Iterator;
import java.util.LinkedList;

public class Queue<E> implements AbstractQueue<E> {
    private LinkedList<E> elements = new LinkedList<>();



    @Override
    public void offer(E element) {
        elements.add(element);
    }

    @Override
    public E poll() {
        checkIsEmpty();
        return elements.removeFirst();
    }

    @Override
    public E peek() {
        checkIsEmpty();
        return elements.getFirst();
    }

    private void checkIsEmpty() {
        if (elements.isEmpty()){
            throw new IllegalStateException();
        }
    }

    @Override
    public int size() {
        return elements.size();
    }

    @Override
    public boolean isEmpty() {
        return elements.isEmpty();
    }

    @Override
    public Iterator<E> iterator() {
        return elements.iterator();
    }
}
