package implementations;

import interfaces.AbstractStack;

import java.util.Iterator;

public class Stack<E> implements AbstractStack<E> {
    private static class Node <E>{
        private E element;
        private E previous;
        private E next;

        public Node(E element) {
            this.element = element;
        }

        public E getElement() {
            return element;
        }

        public E getPrevious() {
            return previous;
        }

        public E getNext() {
            return next;
        }

        public void setElement(E element) {
            this.element = element;
        }

        public void setPrevious(E previous) {
            this.previous = previous;
        }

        public void setNext(E next) {
            this.next = next;
        }
    }

    private Node<E> top;
    private int size;

    public Stack() {
    }

    @Override
    public void push(E element) {
    Node<E> newNode = new Node<>(element);
    newNode.previous = (E) top;
    top = newNode;
    size++;
    }

    @Override
    public E pop() {
        checkIsNoEmpty();
        E element = top.getElement();
        Node<E> temp = (Node<E>)top.previous;
        top.previous = null;
        top = temp;
        size--;
        return element;
    }

    private void checkIsNoEmpty() {
        if (size == 0){
            throw new IllegalStateException ("Stack is empty!");
        }
    }

    @Override
    public E peek() {
        checkIsNoEmpty();
        return top.getElement();
    }

    @Override
    public int size() {
        return size;
    }

    @Override
    public boolean isEmpty() {
        return size == 0;
    }

    @Override
    public Iterator<E> iterator() {
        return new Iterator<E>() {
            private Node<E> current = top;
            @Override
            public boolean hasNext() {
                return current != null;
            }

            @Override
            public E next() {

                E element = current.element;
                current = (Node<E>) current.previous;
                return element;
            }
        };
    }
}
